import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../functions/download_function.dart';
import '../widgets/build_widget.dart';
import '../apis/device.dart';
import '../globals/exception.dart';
import '../models/advertising.dart';
import './player_screen.dart';

class AdvertisementScreen extends StatefulWidget {
  static const routeName = '/advertisement-screen';
  @override
  _AdvertisementScreenState createState() => _AdvertisementScreenState();
}

class _AdvertisementScreenState extends State<AdvertisementScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final Download download = Download();
  final DateTime now = DateTime.now();
  final JsonEncoder jsonEncoder = JsonEncoder();
  final JsonDecoder jsonDecoder = JsonDecoder();
  FocusNode focusNode;
  FocusNode focusNodeDownload;
  String isFirstDownloaded;
  String downloadException = 'Lỗi';

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNodeDownload = FocusNode();
  }

  Duration parseDuration(String time) {
    List<String> times = time.split(':');
    return Duration(
      hours: int.parse(times[0]),
      minutes: int.parse(times[1]),
      seconds: int.parse(times[2]),
    );
  }

  Future<void> initAndDownload(dynamic map) async {
    await download.initDir();
    await download.deleteFile('');
    download.zipPath = 'https://api.pinme.vn${map['data']['url']}';

    await download.downloadZip();

    await download.deleteFile('${download.localZipFileName}');
  }

  Future<List> handlingData(dynamic map) async {
    List collection = map['data']['advertising'];
    List<Advertising> advertisings =
        collection.map((json) => Advertising.fromJson(json)).toList();

    List<Map<String, Object>> datas = List();
    Map<String, Object> data;
    Map<String, String> time;
    List<Map<String, String>> times;

    advertisings.forEach(
      (advertising) => advertising.schedules.forEach(
        (schedule) {
          if (advertising.games.length > 0) {
            time = {
              'start_time': schedule.start_time,
              'end_time': schedule.end_time,
              'advertising_id': schedule.advertising_id.toString(),
              'game_pin': advertising.games[0].game_pin,
            };
          } else {
            time = {
              'start_time': schedule.start_time,
              'end_time': schedule.end_time,
              'advertising_id': schedule.advertising_id.toString(),
              'game_pin': null,
            };
          }

          if (datas.any((data) => data['date'] == schedule.date)) {
            data = datas.firstWhere((data) => data['date'] == schedule.date);
            times = data['times'];
            times.add(time);
          } else {
            datas.add({
              'date': schedule.date,
              'times': [time],
            });
          }
        },
      ),
    );

    datas.forEach((data) {
      times = data['times'];
      times.sort((t1, t2) => parseDuration(t1['start_time'])
          .compareTo(parseDuration(t2['start_time'])));
    });

    printWrapped(datas.toString());

    String datasToString = jsonEncoder.convert(datas);
    String videoFileNames = jsonEncoder.convert(download.videoFileNames);
    String imageFileNames = jsonEncoder.convert(download.imageFileNames);

    await storage.write(key: 'schedules', value: datasToString);
    await storage.write(key: 'video_file_names', value: videoFileNames);
    await storage.write(key: 'image_file_names', value: imageFileNames);
    await storage.write(key: 'dir', value: download.dir);

    return datas;
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<List> downloadAdvertise() async {
    http.Response response;
    try {
      response = await sendDownloadRequest();
      dynamic map = json.decode(response.body);
      if (map['statusCode'] == 'OK') {
        await initAndDownload(map);
        List datas = await handlingData(map);

        await storage.write(key: 'is_downloaded', value: 'true');

        return datas;
      } else if (map['statusCode'] == 'NotFound') {
        throw NoAdvertiseException();
      } else if (map['statusCode'] == 'AdsNotApprove') {
        throw AdvertiseNotApproveException();
      } else {
        print(map['statusCode']);
        throw Exception();
      }
    } on NoAdvertiseException {
      downloadException = 'Chưa có quảng cáo trên thiết bị này';
      return null;
    } on AdvertiseNotApproveException {
      downloadException = 'Quảng cáo chưa được phê duyệt';
      return null;
    } on HandshakeException {
      downloadException = 'Server tạm thời không hoạt động';
      return null;
    } on FormatException {
      downloadException = 'Server tạm thời không hoạt động';
      return null;
    } on SocketException {
      downloadException =
          'Kết nối tới máy chủ thất bại, vui lòng kiểm tra lại đường truyền';
      return null;
    } on http.ClientException {
      downloadException =
          'Kết nối tới máy chủ thất bại, vui lòng kiểm tra lại đường truyền';
      return null;
    } on Exception catch (error) {
      downloadException = 'Đã xảy ra lỗi!';
      print(error.toString());
      return null;
    }
  }

  Future<http.Response> sendDownloadRequest() async {
    String token = await storage.read(key: 'jwt');
    String serialId = await storage.read(key: 'serial_id');
    http.Response response;
    http.Response tokenResponse;
    try {
      response = await downloadAPI(token, serialId);
      dynamic map = json.decode(response.body);
      if (map['statusCode'] == '401') {
        throw TokenException();
      }
    } on TokenException {
      tokenResponse = await refreshTokenAPI(token);
      dynamic map = json.decode(tokenResponse.body);
      if (map['statusCode'] == 'OK') {
        await storage.write(
          key: 'jwt',
          value: map['data'],
        );
        String newToken = await storage.read(key: 'jwt');
        response = await downloadAPI(newToken, serialId);
      }
    }
    return response;
  }

  Future<List> readSchedules() async {
    String schedules = await storage.read(key: 'schedules');
    return jsonDecoder.convert(schedules);
  }

  Future<String> readDir() async {
    return (await storage.read(key: 'dir'));
  }

  Future<List> readVideoFileNames() async {
    String videoFileNames = await storage.read(key: 'video_file_names');
    return jsonDecoder.convert(videoFileNames);
  }

  Future<List> readImageFileNames() async {
    String imageFileNames = await storage.read(key: 'image_file_names');
    return jsonDecoder.convert(imageFileNames);
  }

  Widget buildContainer(Size size) {
    Future.delayed(Duration(seconds: 0), () {
      Navigator.of(context).pushReplacementNamed(PlayerScreen.routeName);
    });
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.red,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: size.width * 0.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    return FutureBuilder<List>(
      future: downloadAdvertise(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return buildContainer(size);
          } else
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      downloadException,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.03),
                    GestureDetector(
                      onTap: () {
                        setState(() {});
                      },
                      child: Container(
                        height: size.height * 0.05,
                        width: size.width * 0.2,
                        color: Colors.blue,
                        child: Center(child: Text('Tải lại')),
                      ),
                    )
                  ],
                ),
              ),
            );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // CircularProgressIndicator(),
                  // SizedBox(height: size.height * 0.03),
                  Text('Đang tải quảng cáo...'),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    focusNodeDownload.dispose();
    super.dispose();
  }
}
