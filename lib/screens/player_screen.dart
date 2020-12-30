import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../blocs/advertise_bloc.dart';
import '../blocs/controller_index_bloc.dart';
import '../blocs/video_bloc.dart';
import '../blocs/image_bloc.dart';
import '../blocs/image_ad_bloc.dart';
import '../blocs/image_index_bloc.dart';
import '../blocs/game_bloc.dart';
import '../widgets/player_child.dart';

class PlayerScreen extends StatefulWidget {
  static const routeName = '/player-screen';

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  JsonDecoder jsonDecoder = JsonDecoder();
  List videoFileNames;
  List imageFileNames;
  List<List> videos = List();
  List<List> images = List();
  List games = List();
  String dir;
  List datas;
  bool isFirstCase;

  Future<void> initData() async {
    datas = jsonDecoder.convert(await storage.read(key: 'schedules'));
    videoFileNames =
        jsonDecoder.convert(await storage.read(key: 'video_file_names'));
    imageFileNames =
        jsonDecoder.convert(await storage.read(key: 'image_file_names'));
    dir = await storage.read(key: 'dir');

    DateTime now = DateTime.now();
    String today = DateFormat('yyyy-MM-dd').format(now);
    Duration timeNow =
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second);

    datas = datas.where((data) {
      DateTime date = DateTime.parse(data['date']);
      return date.compareTo(DateTime.parse(today)) != -1;
    }).toList();

    List times;
    datas.forEach((data) {
      times = data['times'];
      if (data['date'] == today) {
        times.removeWhere((time) {
          return timeNow.compareTo(Duration(
                  milliseconds:
                      parseDuration(time['end_time']).inMilliseconds - 15200)) ==
              1;
        });
      }
    });

    datas.removeWhere((data) {
      times = data['times'];
      return times.length == 0;
    });

    if (datas.length > 0) {
      String nearestDate = datas[0]['date'];
      String nearestStartTime = datas[0]['times'][0]['start_time'];

      now = DateTime.now();

      if (nearestDate != today ||
          timeNow.compareTo(Duration(
                  milliseconds:
                      parseDuration(nearestStartTime).inMilliseconds - 5200)) ==
              -1) {
        videos.add([]);
        images.add([]);
        games.add([]);
        initAdvertise();
        isFirstCase = true;
      } else {
        initAdvertise();
        isFirstCase = false;
      }
    } else {
      videos.add([]);
      images.add([]);
      games.add([]);
      isFirstCase = true;
    }
  }

  void initAdvertise() {
    List times;
    datas.forEach((data) {
      times = data['times'];
      times.forEach((time) {
        videos.add(videoFileNames
            .where((videoFileName) =>
                videoFileName.startsWith(time['advertising_id']))
            .toList());
        images.add(imageFileNames
            .where((imageFileName) =>
                imageFileName.startsWith(time['advertising_id']))
            .toList());
        games.add(time['game_pin']);
      });
    });
  }

  Duration parseDuration(String time) {
    List<String> times = time.split(':');
    return Duration(
      hours: int.parse(times[0]),
      minutes: int.parse(times[1]),
      seconds: int.parse(times[2]),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: initData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (ctx) => AdvertiseBloc(),
                ),
                BlocProvider(
                  create: (ctx) => ControllerIndexBloc(),
                ),
                BlocProvider(
                  create: (ctx) => VideoBloc(),
                ),
                BlocProvider(
                  create: (ctx) => ImageBloc(),
                ),
                BlocProvider(
                  create: (ctx) => ImageAdIndexBloc(),
                ),
                BlocProvider(
                  create: (ctx) => ImageIndexBloc(),
                ),
                BlocProvider(
                  create: (ctx) => GameBloc(),
                ),
              ],
              child: PlayerChild(datas, dir, videos, images, games, isFirstCase),
            );
          else
            return Container(
              height: size.height,
              width: size.width,
              color: Colors.yellow,
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: size.width * 0.6,
                ),
              ),
            );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
