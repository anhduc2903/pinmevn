import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info/device_info.dart';
import 'package:open_settings/open_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:location/location.dart' as lct;
import 'package:http/http.dart' as http;

import '../screens/signup_first_screen.dart';
import '../screens/signin_email_screen.dart';
import '../screens/signin_code_screen.dart';
import '../screens/signup_second_screen.dart';
import '../screens/advertisement_screen.dart';
import '../models/device.dart';
import '../models/signin.dart';
import '../apis/user_publisher.dart';
import '../globals/exception.dart';
import '../globals/globals.dart' as globals;

void toSignInEmailScreen(BuildContext context) {
  Navigator.pushReplacementNamed(context, SignInEmailScreen.routeName);
}

void toSignInCodeScreen(BuildContext context) {
  Navigator.pushReplacementNamed(context, SignInCodeScreen.routeName);
}

void toSignUpFirstScreen(BuildContext context) {
  Navigator.pushReplacementNamed(context, SignUpFirstScreen.routeName);
}

void returnSignUpFirstScreen(BuildContext context) {
  Navigator.of(context).pop();
}

void toSignUpSecondScreen(
  BuildContext context,
  List<TextEditingController> controllers,
) {
  globals.signIn = SignIn(
    name: controllers[0].text,
    phone: controllers[1].text,
    email: controllers[2].text,
    password: controllers[3].text,
  );
  Navigator.pushNamed(context, SignUpSecondScreen.routeName);
}

Future<void> signUp(BuildContext context) async {
  print(globals.signIn.name);
  print(globals.signIn.phone);
  print(globals.signIn.email);
  print(globals.signIn.password);
}

Future<void> signIn({
  BuildContext context,
  List<TextEditingController> controllers,
  ScaffoldState scaffoldState,
  FormState formState,
  String invalidAccount,
  bool isLandScape,
}) async {
  final storage = FlutterSecureStorage();
  if (formState.validate()) {
    try {
      // print(globals.device.serial_id);
      if (globals.device == null) throw DeviceInfoException();
      await requestDeviceLocation();
      http.Response response = await signInAPI(controllers);
      if (json.decode(response.body)["statusCode"] == 'OK') {
        await storage.write(
          key: 'jwt',
          value: json.decode(response.body)["data"]["user"]["access_token"],
        );
        await storage.write(
          key: 'serial_id',
          value: globals.device.serial_id,
        );
        Navigator.pushReplacementNamed(context, AdvertisementScreen.routeName);
      } else if (json.decode(response.body)["statusCode"] == 'DeviceNotMatch') {
        throw DeviceNotMatchException();
      } else {
        throw InvalidAccountException();
      }
    } on LocationPermissionException catch (error) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } on LocationServiceException catch (error) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } on LocationLandScapeException catch (error) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
      if (isLandScape) OpenSettings.openLocationSetting();
    } on DeviceInfoException catch (error) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } on DeviceNotMatchException catch (error) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } on InvalidAccountException {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text(
            invalidAccount,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } on InternetConnectionException catch (error) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}

Future<void> requestDeviceLocation() async {
  var connectivityResult;
  Position position;
  lct.Location location;
  bool serviceEnable;
  lct.PermissionStatus permissionStatus;
  bool requestService;

  try {
    connectivityResult = await Connectivity().checkConnectivity();
    // print(connectivityResult.toString());
    if (connectivityResult == ConnectivityResult.none) {
      throw InternetConnectionException();
    }
    location = lct.Location();
    await location.requestPermission();
    permissionStatus = await location.hasPermission();

    if (permissionStatus == lct.PermissionStatus.GRANTED) {
      serviceEnable = await location.serviceEnabled();
      if (!serviceEnable) {
        requestService = await location.requestService();
      }
      if (serviceEnable || requestService) {
        position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        globals.position = position;
      } else {
        throw LocationServiceException();
      }
    } else {
      throw LocationPermissionException();
    }
  } on PlatformException {
    throw LocationLandScapeException();
  }
}

Future<void> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
  globals.device = Device(
    serial_id: deviceInfo.androidId,
    name: deviceInfo.model,
  );
}

String emailValidator(String value) {
  if (value.isEmpty) {
    return "Bạn chưa nhập dữ liệu";
  }
  if (!EmailValidator.validate(value)) {
    return "Định dạng email chưa chính xác";
  }
  return null;
}

String inputValidator(String value) {
  if (value.isEmpty) {
    return "Bạn chưa nhập dữ liệu";
  }
  return null;
}
