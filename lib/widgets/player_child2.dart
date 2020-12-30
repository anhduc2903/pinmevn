import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../screens/advertisement_screen.dart';

class PlayerChild extends StatefulWidget {
  final VideoPlayerController controller;
  final List datas;
  final String dir;
  final List videoFileNames;
  final List imageFileNames;
  final List videos;
  final List images;
  PlayerChild(
    this.controller,
    this.datas,
    this.dir,
    this.videoFileNames,
    this.imageFileNames,
    this.videos,
    this.images,
  );

  @override
  _PlayerChildState createState() => _PlayerChildState();
}

class _PlayerChildState extends State<PlayerChild> {
  bool isLandScape;
  List datas;
  Timer timer;
  bool changeLock = false;
  int videoIndex = 0;
  int imageIndex = 0;
  String dir;
  List videoTemp = List();
  List imageTemp = List();
  List videoFileNames;
  List imageFileNames;
  List videos;
  List images;
  List<VideoPlayerController> controllers = [];
  VideoPlayerController controllerTemp;

  @override
  void initState() {
    super.initState();
    datas = widget.datas;
    dir = widget.dir;
    videoFileNames = widget.videoFileNames;
    imageFileNames = widget.imageFileNames;
    videos = widget.videos;
    images = widget.images;

    controllers.add(null);
    if (widget.controller != null) {
      initControllers();

      timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        imageCache.clear();
        imageIndex = imageIndex < images.length - 1 ? imageIndex + 1 : 0;
        await precacheImage(
            FileImage(File('$dir/${images[imageIndex]}')), context);
        setState(() {});
      });

      initCalendarFirstCase();
    } else if (images.length > 0) {
      controllers.add(null);
      controllers.add(null);

      if (images.length > 1) {
        timer = Timer.periodic(Duration(seconds: 5), (timer) async {
          imageCache.clear();
          imageIndex = imageIndex < images.length - 1 ? imageIndex + 1 : 0;
          await precacheImage(
              FileImage(File('$dir/${images[imageIndex]}')), context);
          setState(() {});
        });
      }

      initCalendarFirstCase();
    } else {
      controllers.add(null);
      controllers.add(null);

      initCalendarSecondCase();
    }
  }

  void initCalendarFirstCase() {
    DateTime now = DateTime.now();

    datas.forEach((data) {
      List times = data['times'];
      String date = data['date'];
      times.forEach((time) {
        if ((data == datas[0] && time != times[0]) || data != datas[0]) {
          Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['start_time']}')
                      .subtract(Duration(milliseconds: 2200))
                      .difference(now)
                      .inMilliseconds), () {
            videoTemp.clear();
            videoTemp.addAll(videoFileNames
                .where((videoFileName) =>
                    videoFileName.startsWith(time['advertising_id']))
                .toList());
            imageTemp.clear();
            imageTemp.addAll(imageFileNames
                .where((imageFileName) =>
                    imageFileName.startsWith(time['advertising_id']))
                .toList());
            timer?.cancel();
            imageCache.clear();
            if (imageTemp.length > 0) {
              precacheImage(FileImage(File('$dir/${imageTemp[0]}')), context);
            }
            if (videoTemp.length > 0) {
              controllerTemp =
                  VideoPlayerController.file(File('$dir/${videoTemp[0]}'));
              attachListenerAndInit(controllerTemp);
            }
          });

          Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['start_time']}')
                      .subtract(Duration(milliseconds: 200))
                      .difference(now)
                      .inMilliseconds), () {
            videos.clear();
            videos.addAll(videoFileNames
                .where((videoFileName) =>
                    videoFileName.startsWith(time['advertising_id']))
                .toList());
            images.clear();
            images.addAll(imageFileNames
                .where((imageFileName) =>
                    imageFileName.startsWith(time['advertising_id']))
                .toList());
            videoIndex = 0;
            imageIndex = 0;
            if (videos.length > 0) {
              nextAdvertiseVideo();
            } else {
              changeLock = true;
              setState(() {});
            }

            if (images.length > 1) {
              timer = Timer.periodic(Duration(seconds: 5), (timer) async {
                imageCache.clear();
                imageIndex =
                    imageIndex < images.length - 1 ? imageIndex + 1 : 0;
                await precacheImage(
                    FileImage(File('$dir/${images[imageIndex]}')), context);
                setState(() {});
              });
            }
          });
        }

        if (times.indexOf(time) + 1 != times.length &&
            time['end_time'] != times[times.indexOf(time) + 1]['start_time']) {
          Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['end_time']}')
                      .subtract(Duration(milliseconds: 200))
                      .difference(now)
                      .inMilliseconds), () {
            controllers[1].pause();
            timer?.cancel();
            setState(() {
              videos.clear();
              images.clear();
            });
          });
        }
      });
    });
  }

  void initCalendarSecondCase() {
    DateTime now = DateTime.now();

    datas.forEach((data) {
      List times = data['times'];
      String date = data['date'];
      times.forEach((time) {
        Timer(
            Duration(
                milliseconds: DateTime.parse('$date ${time['start_time']}')
                    .subtract(Duration(milliseconds: 2200))
                    .difference(now)
                    .inMilliseconds), () {
          videoTemp.clear();
          videoTemp.addAll(videoFileNames
              .where((videoFileName) =>
                  videoFileName.startsWith(time['advertising_id']))
              .toList());
          imageTemp.clear();
          imageTemp.addAll(imageFileNames
              .where((imageFileName) =>
                  imageFileName.startsWith(time['advertising_id']))
              .toList());
          timer?.cancel();
          imageCache.clear();
          if (imageTemp.length > 0) {
            precacheImage(FileImage(File('$dir/${imageTemp[0]}')), context);
          }
          if (videoTemp.length > 0) {
            controllerTemp =
                VideoPlayerController.file(File('$dir/${videoTemp[0]}'));
            attachListenerAndInit(controllerTemp);
          }
        });

        Timer(
            Duration(
                milliseconds: DateTime.parse('$date ${time['start_time']}')
                    .subtract(Duration(milliseconds: 200))
                    .difference(now)
                    .inMilliseconds), () {
          videos.clear();
          videos.addAll(videoFileNames
              .where((videoFileName) =>
                  videoFileName.startsWith(time['advertising_id']))
              .toList());
          images.clear();
          images.addAll(imageFileNames
              .where((imageFileName) =>
                  imageFileName.startsWith(time['advertising_id']))
              .toList());
          videoIndex = 0;
          imageIndex = 0;
          if (videos.length > 0) {
            nextAdvertiseVideo();
          } else {
            changeLock = true;
            setState(() {});
          }

          if (images.length > 1) {
            timer = Timer.periodic(Duration(seconds: 5), (timer) async {
              imageCache.clear();
              imageIndex = imageIndex < images.length - 1 ? imageIndex + 1 : 0;
              await precacheImage(
                  FileImage(File('$dir/${images[imageIndex]}')), context);
              setState(() {});
            });
          }
        });

        if (times.indexOf(time) + 1 != times.length &&
            time['end_time'] != times[times.indexOf(time) + 1]['start_time']) {
          // if (data == datas[0] && times.indexOf(time) + 1 != times.length)
          //   print(
          //       time['end_time'] != times[times.indexOf(time) + 1]['start_time']);
          Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['end_time']}')
                      .subtract(Duration(milliseconds: 200))
                      .difference(now)
                      .inMilliseconds), () {
            controllers[1].pause();
            timer?.cancel();
            setState(() {
              videos.clear();
              images.clear();
            });
          });
        }
      });
    });
  }

  initControllers() {
    controllers.add(widget.controller);
    if (videos.length > 1) {
      controllers.add(VideoPlayerController.file(File('$dir/${videos[1]}')));
    } else {
      controllers.add(VideoPlayerController.file(File('$dir/${videos[0]}')));
    }

    attachListener(controllers[1]).then((_) {
      controllers[1].play();
    });

    attachListenerAndInit(controllers[2]);
  }

  Future<void> attachListener(VideoPlayerController controller) async {
    if (!controller.hasListeners) {
      controller.addListener(() {
        int dur = controller.value.duration.inMilliseconds;
        int pos = controller.value.position.inMilliseconds;
        if (dur - pos < 1) {
          nextVideo();
        }
      });
    }
  }

  Future<void> attachListenerAndInit(VideoPlayerController controller) async {
    if (!controller.hasListeners) {
      controller.addListener(() {
        int dur = controller.value.duration.inMilliseconds;
        int pos = controller.value.position.inMilliseconds;
        if (dur - pos < 1) {
          nextVideo();
        }
      });
    }
    await controller.initialize();
    return;
  }

  Future<void> nextAdvertiseVideo() async {
    changeLock = true;

    controllers.last?.dispose();
    controllers.removeAt(2);
    controllers[1]?.pause();

    controllers.first?.dispose();
    controllers.removeAt(0);

    controllers.add(controllerTemp);

    controllers.add(VideoPlayerController.file(File(
        '$dir/${videos[videoIndex < videos.length - 1 ? videoIndex + 1 : 0]}')));

    attachListenerAndInit(controllers.last);

    controllers[1].play().then((_) {
      setState(() {
        changeLock = false;
      });
    });
  }

  Future<void> nextVideo() async {
    if (changeLock) {
      return;
    }
    changeLock = true;

    controllers[1]?.pause();
    videoIndex = videoIndex < videos.length - 1 ? videoIndex + 1 : 0;
    controllers.first?.dispose();
    controllers.removeAt(0);

    controllers.add(VideoPlayerController.file(File(
        '$dir/${videos[videoIndex < videos.length - 1 ? videoIndex + 1 : 0]}')));

    attachListenerAndInit(controllers.last);

    controllers[1].play().then((_) {
      setState(() {
        changeLock = false;
      });
    });
  }

  Widget buildAdvertisePortrait() {
    print('A');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayer(controllers[1]),
        ),
        Container(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).size.width * 9 / 16,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.file(File('$dir/${images[imageIndex]}')),
            ],
          ),
        )
      ],
    );
  }

  Widget buildAdvertiseLandScape() {
    print('A');
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width * 0.6 * 9 / 16,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayer(controllers[1]),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Image.file(
            File(
              '$dir/${images[imageIndex]}',
            ),
            fit: BoxFit.contain,
          ),
        )
      ],
    );
  }

  Widget buildVideo() {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayer(controllers[1]),
      ),
    );
  }

  Widget buildImage() {
    return Center(
      child: Image.file(File('$dir/${images[imageIndex]}')),
    );
  }

  Widget body(Size size, bool isLandScape) {
    if (videos.length > 0 && images.length > 0) {
      return isLandScape ? buildAdvertiseLandScape() : buildAdvertisePortrait();
    } else if (videos.length > 0) {
      return buildVideo();
    } else if (images.length > 0) {
      return buildImage();
    } else {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Không có quảng cáo nào đang chạy'),
              SizedBox(height: size.height * 0.03),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushReplacementNamed(AdvertisementScreen.routeName);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    final bool isLandScape = mediaQuery.orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Colors.black,
      body: body(size, isLandScape),
    );
  }

  @override
  void dispose() {
    controllers.forEach((controller) {
      controller?.dispose();
    });
    super.dispose();
  }
}
