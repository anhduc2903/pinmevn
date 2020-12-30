import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screen/screen.dart';

import './screens/signin_code_screen.dart';
import './screens/signin_email_screen.dart';
import './screens/signup_first_screen.dart';
import './screens/signup_second_screen.dart';
import './screens/advertisement_screen.dart';
import './screens/player_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();
  String idToken;
  String isDownloaded;

  @override
  void initState() {
    super.initState();
    Screen.keepOn(true);
  }

  Future<String> futureBuilder() async {
    imageCache.clear();
    await precacheImage(AssetImage('assets/images/logo.png'), context);
    idToken = await storage.read(key: 'jwt');
    isDownloaded = await storage.read(key: 'is_downloaded');
    return idToken;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: futureBuilder(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textTheme: TextTheme(),
            ),
            initialRoute: snapshot.data == null
                ? SignInCodeScreen.routeName
                : isDownloaded != 'true'
                    ? AdvertisementScreen.routeName
                    : PlayerScreen.routeName,
            routes: {
              SignInEmailScreen.routeName: (ctx) => SignInEmailScreen(),
              SignInCodeScreen.routeName: (ctx) => SignInCodeScreen(),
              SignUpFirstScreen.routeName: (ctx) => SignUpFirstScreen(),
              SignUpSecondScreen.routeName: (ctx) => SignUpSecondScreen(),
              AdvertisementScreen.routeName: (ctx) => AdvertisementScreen(),
              PlayerScreen.routeName: (ctx) => PlayerScreen(),
            },
          );
        else
          return Container(
            color: Colors.black,
          );
      },
    );
  }
}
