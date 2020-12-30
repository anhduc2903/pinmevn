import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:video_player/video_player.dart';

import '../screens/advertisement_screen.dart';
import '../blocs/advertise_bloc.dart';
import '../blocs/controller_index_bloc.dart';
import '../blocs/video_bloc.dart';
import '../blocs/image_bloc.dart';
import '../blocs/image_ad_bloc.dart';
import '../blocs/image_index_bloc.dart';
import '../blocs/game_bloc.dart';

class PlayerChild extends StatefulWidget {
  final List datas;
  final String dir;
  final List<List> videos;
  final List<List> images;
  final List games;
  final bool isFirstCase;

  PlayerChild(this.datas, this.dir, this.videos, this.images, this.games,
      this.isFirstCase);

  @override
  _PlayerChildState createState() => _PlayerChildState();
}

class _PlayerChildState extends State<PlayerChild> with WidgetsBindingObserver {
  List<VideoPlayerController> controllers = [null, null];
  List<List> videos;
  List<List> images;
  List games;
  String dir;
  List datas;
  bool changeLock = false;
  bool lastTwo = false;
  Timer periodic;
  List<Timer> timers = List();
  bool isFirstCase;

  int controllerIndex = 0;
  int previousControllerIndex = 1;
  int videoIndex = 0;
  int imageIndex = 0;
  int videoAdIndex = 0;
  int imageAdIndex = 0;
  int nextVideoAdIndex = 0;
  int nextImageAdIndex = 0;
  int tempControllerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Timer(Duration(seconds: 20), () {
    //   Navigator.of(context).pushReplacementNamed(AdvertisementScreen.routeName);
    // });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        timers.forEach((timer) => timer?.cancel());
        periodic?.cancel();
        imageCache.clear();
        await controllers[0]?.dispose();
        await controllers[1]?.dispose();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  Future<void> initVideo() async {
    datas = widget.datas;
    dir = widget.dir;
    videos = widget.videos;
    images = widget.images;
    games = widget.games;
    isFirstCase = widget.isFirstCase;

    if (videos[videoAdIndex].length != 0 || images[imageAdIndex].length != 0) {
      changeAdvertiseStatus(true);
    }

    if (videos[videoAdIndex].length > 0) {
      changeVideoStatus(true);
      controllers[0] =
          VideoPlayerController.file(File('$dir/${videos[0][videoIndex]}'));
      videoIndex = videoIndex < videos[0].length - 1 ? videoIndex + 1 : 0;
      controllers[1] =
          VideoPlayerController.file(File('$dir/${videos[0][videoIndex]}'));

      await controllers[0].initialize();
      attachListener(controllers[0]);
      await controllers[1].initialize();
    }

    if (images[imageAdIndex].length > 0) {
      changeImageStatus(true);
      imageCache.clear();
      await precacheImage(FileImage(File('$dir/${images[0][0]}')), context);
      if (images[imageAdIndex].length > 1) {
        loopImages();
      }
    }

    if (games[imageAdIndex] != null) {
      changeGameStatus(true);
    }

    if (datas.length > 0) {
      if (isFirstCase) {
        initScheduleFirstCase();
      } else {
        initScheduleSecondCase();
        Future.delayed(Duration(milliseconds: 200), () {
          controllers[0]?.play();
        });
      }
    } else {}
  }

  void initScheduleFirstCase() {
    DateTime now = DateTime.now();

    datas.forEach((data) {
      String date = data['date'];
      List times = data['times'];

      times.forEach((time) {
        timers.add(
          Timer(
            Duration(
                milliseconds: DateTime.parse('$date ${time['start_time']}')
                    .subtract(Duration(milliseconds: 5200))
                    .difference(now)
                    .inMilliseconds),
            () async {
              print('5');
              nextVideoAdIndex++;
              if (videos[nextVideoAdIndex].length > 0) {
                await controllers[previousControllerIndex]?.dispose();
                controllers[previousControllerIndex] =
                    VideoPlayerController.file(
                        File('$dir/${videos[nextVideoAdIndex][0]}'));
                await controllers[previousControllerIndex].initialize();
              }

              nextImageAdIndex++;
              imageCache.clear();
              if (images[nextImageAdIndex].length > 0) {
                await precacheImage(
                    FileImage(File('$dir/${images[nextImageAdIndex][0]}')),
                    context);
              }
            },
          ),
        );

        timers.add(
          Timer(
            Duration(
                milliseconds: DateTime.parse('$date ${time['start_time']}')
                    .subtract(Duration(milliseconds: 200))
                    .difference(now)
                    .inMilliseconds),
            () async {
              print('6');
              videoAdIndex = nextVideoAdIndex;
              imageAdIndex = nextImageAdIndex;

              changeAdvertiseStatus(true);

              if (images[imageAdIndex].length > 0) {
                BlocProvider.of<ImageIndexBloc>(context)
                    .add(ImageIndexEvents.previous);
                changeImageStatus(true);
                changeImageAdIndex();

                imageIndex = 0;
                loopImages();
              } else {
                periodic?.cancel();
                changeImageStatus(false);
                changeImageAdIndex();
              }

              if (games[imageAdIndex] != null) {
                changeGameStatus(true);
              } else {
                changeGameStatus(false);
              }

              if (videos[videoAdIndex].length > 0) {
                changeVideoStatus(true);
                previousControllerIndex = controllerIndex;
                controllerIndex = controllerIndex == 0 ? 1 : 0;
                videoIndex = 0;
                await controllers[previousControllerIndex]?.pause();
                changeControllerIndex();
                await controllers[controllerIndex].play();
                attachListener(controllers[controllerIndex]);

                await disposePreviousController();
                lastTwo = false;
              } else {
                changeVideoStatus(false);
                Future.delayed(Duration(milliseconds: 200), () async {
                  await controllers[previousControllerIndex]?.dispose();
                  controllers[previousControllerIndex] = null;
                  await controllers[controllerIndex]?.pause();
                  await controllers[controllerIndex]?.dispose();
                  controllers[tempControllerIndex] = null;
                });
              }
            },
          ),
        );

        timers.add(
          Timer(
            Duration(
                milliseconds: DateTime.parse('$date ${time['end_time']}')
                    .subtract(Duration(milliseconds: 10200))
                    .difference(now)
                    .inMilliseconds),
            () async {
              print('7');
              lastTwo = true;
              changeLock = true;
              periodic?.cancel();
            },
          ),
        );

        if (times.indexOf(time) + 1 == times.length ||
            (times.indexOf(time) + 1 != times.length &&
                time['end_time'] !=
                    times[times.indexOf(time) + 1]['start_time'])) {
          timers.add(
            Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['end_time']}')
                      .subtract(Duration(milliseconds: 200))
                      .difference(now)
                      .inMilliseconds),
              () async {
                print('8');
                changeAdvertiseStatus(false);
                changeVideoStatus(false);
                changeImageStatus(false);
                changeGameStatus(false);
                imageCache.clear();
                periodic?.cancel();
                Future.delayed(Duration(milliseconds: 200), () async {
                  await controllers[previousControllerIndex]?.dispose();
                  controllers[previousControllerIndex] = null;
                  await controllers[controllerIndex]?.pause();
                  await controllers[controllerIndex]?.dispose();
                  controllers[controllerIndex] = null;
                });
              },
            ),
          );
        }
      });
    });
  }

  void initScheduleSecondCase() {
    DateTime now = DateTime.now();

    datas.forEach((data) {
      String date = data['date'];
      List times = data['times'];

      times.forEach((time) {
        if ((data == datas[0] && time != times[0]) || data != datas[0]) {
          timers.add(
            Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['start_time']}')
                      .subtract(Duration(milliseconds: 5200))
                      .difference(now)
                      .inMilliseconds),
              () async {
                print('1');
                nextVideoAdIndex++;
                if (videos[nextVideoAdIndex].length > 0) {
                  await controllers[previousControllerIndex]?.dispose();
                  controllers[previousControllerIndex] =
                      VideoPlayerController.file(
                          File('$dir/${videos[nextVideoAdIndex][0]}'));
                  await controllers[previousControllerIndex].initialize();
                }

                nextImageAdIndex++;
                imageCache.clear();
                if (images[nextImageAdIndex].length > 0) {
                  await precacheImage(
                      FileImage(File('$dir/${images[nextImageAdIndex][0]}')),
                      context);
                }
              },
            ),
          );

          timers.add(
            Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['start_time']}')
                      .subtract(Duration(milliseconds: 200))
                      .difference(now)
                      .inMilliseconds),
              () async {
                print('2');
                videoAdIndex = nextVideoAdIndex;
                imageAdIndex = nextImageAdIndex;

                changeAdvertiseStatus(true);

                if (images[imageAdIndex].length > 0) {
                  BlocProvider.of<ImageIndexBloc>(context)
                      .add(ImageIndexEvents.previous);
                  changeImageStatus(true);
                  changeImageAdIndex();

                  imageIndex = 0;
                  loopImages();
                } else {
                  periodic?.cancel();
                  changeImageStatus(false);
                  changeImageAdIndex();
                }

                if (games[imageAdIndex] != null) {
                  changeGameStatus(true);
                } else {
                  changeGameStatus(false);
                }

                if (videos[videoAdIndex].length > 0) {
                  changeVideoStatus(true);
                  previousControllerIndex = controllerIndex;
                  controllerIndex = controllerIndex == 0 ? 1 : 0;
                  videoIndex = 0;
                  await controllers[previousControllerIndex]?.pause();
                  changeControllerIndex();
                  await controllers[controllerIndex].play();
                  attachListener(controllers[controllerIndex]);

                  await disposePreviousController();
                  lastTwo = false;
                } else {
                  changeVideoStatus(false);
                  Future.delayed(Duration(milliseconds: 200), () async {
                    await controllers[previousControllerIndex]?.dispose();
                    controllers[previousControllerIndex] = null;
                    await controllers[controllerIndex]?.pause();
                    await controllers[controllerIndex]?.dispose();
                    controllers[tempControllerIndex] = null;
                  });
                }
              },
            ),
          );
        }

        timers.add(
          Timer(
            Duration(
                milliseconds: DateTime.parse('$date ${time['end_time']}')
                    .subtract(Duration(milliseconds: 10200))
                    .difference(now)
                    .inMilliseconds),
            () async {
              print('3');
              lastTwo = true;
              changeLock = true;
              periodic?.cancel();
            },
          ),
        );

        if (times.indexOf(time) + 1 == times.length ||
            (times.indexOf(time) + 1 != times.length &&
                time['end_time'] !=
                    times[times.indexOf(time) + 1]['start_time'])) {
          timers.add(
            Timer(
              Duration(
                  milliseconds: DateTime.parse('$date ${time['end_time']}')
                      .subtract(Duration(milliseconds: 200))
                      .difference(now)
                      .inMilliseconds),
              () async {
                print('4');
                changeAdvertiseStatus(false);
                changeVideoStatus(false);
                changeImageStatus(false);
                changeGameStatus(false);
                imageCache.clear();
                periodic?.cancel();
                Future.delayed(Duration(milliseconds: 200), () async {
                  await controllers[previousControllerIndex]?.dispose();
                  controllers[previousControllerIndex] = null;
                  await controllers[controllerIndex]?.pause();
                  await controllers[controllerIndex]?.dispose();
                  controllers[controllerIndex] = null;
                });
              },
            ),
          );
        }
      });
    });
  }

  void attachListener(VideoPlayerController controller) {
    controller.addListener(() async {
      int dur = controller.value.duration.inMilliseconds;
      int pos = controller.value.position.inMilliseconds;
      if (pos > dur - 1) {
        if (lastTwo == true)
          await controller.seekTo(Duration.zero);
        else
          nextVideo();
      }
    });
  }

  Future<void> nextVideo() async {
    if (changeLock == true) {
      return;
    }
    changeLock = true;

    previousControllerIndex = controllerIndex;
    controllerIndex = controllerIndex == 0 ? 1 : 0;

    changeControllerIndex();
    await controllers[controllerIndex].play();
    attachListener(controllers[controllerIndex]);

    await disposePreviousController();
  }

  Future<void> disposePreviousController() async {
    await Future.delayed(Duration(milliseconds: 200), () async {
      await controllers[previousControllerIndex]?.dispose();
      await initPreviousController();
    });
  }

  Future<void> initPreviousController() async {
    videoIndex =
        videoIndex < videos[videoAdIndex].length - 1 ? videoIndex + 1 : 0;
    controllers[previousControllerIndex] = VideoPlayerController.file(
        File('$dir/${videos[videoAdIndex][videoIndex]}'));
    await controllers[previousControllerIndex].initialize();
    changeLock = false;
  }

  Duration parseDuration(String time) {
    List<String> times = time.split(':');
    return Duration(
      hours: int.parse(times[0]),
      minutes: int.parse(times[1]),
      seconds: int.parse(times[2]),
    );
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  void loopImages() {
    periodic = Timer.periodic(
      Duration(seconds: 5),
      (timer) async {
        imageIndex =
            imageIndex < images[imageAdIndex].length - 1 ? imageIndex + 1 : 0;
        imageCache.clear();
        await precacheImage(
            FileImage(File('$dir/${images[imageAdIndex][imageIndex]}')),
            context);
        changeImageIndex();
      },
    );
  }

  void changeGameStatus(bool status) {
    status == true
        ? BlocProvider.of<GameBloc>(context).add(GameEvents.yes)
        : BlocProvider.of<GameBloc>(context).add(GameEvents.no);
  }

  void changeImageIndex() {
    if (periodic.isActive)
      imageIndex == 0
          ? BlocProvider.of<ImageIndexBloc>(context)
              .add(ImageIndexEvents.previous)
          : BlocProvider.of<ImageIndexBloc>(context)
              .add(ImageIndexEvents.conjunctive);
  }

  void changeImageAdIndex() {
    imageAdIndex == 0
        ? BlocProvider.of<ImageAdIndexBloc>(context)
            .add(ImageAdIndexEvents.previous)
        : BlocProvider.of<ImageAdIndexBloc>(context)
            .add(ImageAdIndexEvents.conjunctive);
  }

  void changeImageStatus(bool status) {
    status == true
        ? BlocProvider.of<ImageBloc>(context).add(ImageEvents.yes)
        : BlocProvider.of<ImageBloc>(context).add(ImageEvents.no);
  }

  void changeControllerIndex() {
    controllerIndex == 0
        ? BlocProvider.of<ControllerIndexBloc>(context)
            .add(ControllerIndexEvents.previous)
        : BlocProvider.of<ControllerIndexBloc>(context)
            .add(ControllerIndexEvents.conjunctive);
  }

  void changeVideoStatus(bool status) {
    status == true
        ? BlocProvider.of<VideoBloc>(context).add(VideoEvents.yes)
        : BlocProvider.of<VideoBloc>(context).add(VideoEvents.no);
  }

  void changeAdvertiseStatus(bool status) {
    status == true
        ? BlocProvider.of<AdvertiseBloc>(context).add(AdvertiseEvents.yes)
        : BlocProvider.of<AdvertiseBloc>(context).add(AdvertiseEvents.no);
  }

  Widget buildAdvertisePortrait(Size size) {
    return Column(
      children: <Widget>[
        BlocBuilder<VideoBloc, bool>(
          builder: (context, videoState) {
            return videoState == true
                ? BlocBuilder<ControllerIndexBloc, int>(
                    builder: (context, controllerIndexState) {
                      return BlocBuilder<ImageBloc, bool>(
                        builder: (context, imageState) {
                          return imageState
                              ? SizedBox(
                                  width: size.width,
                                  height: size.width * 9 / 16,
                                  child: VideoPlayer(
                                      controllers[controllerIndexState]),
                                )
                              : SizedBox(
                                  width: size.width,
                                  height: size.height,
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: VideoPlayer(
                                        controllers[controllerIndexState]),
                                  ),
                                );
                        },
                      );
                    },
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  );
          },
        ),
        BlocBuilder<ImageBloc, bool>(
          builder: (context, imageState) {
            return imageState == true
                ? BlocBuilder<ImageAdIndexBloc, int>(
                    builder: (context, imageAdIndexState) {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          BlocBuilder<ImageIndexBloc, int>(
                            builder: (context, imageIndexState) {
                              return BlocBuilder<VideoBloc, bool>(
                                builder: (context, videoState) {
                                  return videoState
                                      ? SizedBox(
                                          width: size.width,
                                          height:
                                              size.height - size.width * 9 / 16,
                                          child: Image.file(
                                            File(
                                                '$dir/${images[imageAdIndexState][imageIndexState]}'),
                                          ),
                                        )
                                      : SizedBox(
                                          width: size.width,
                                          height: size.height,
                                          child: Image.file(
                                            File(
                                                '$dir/${images[imageAdIndexState][imageIndexState]}'),
                                          ),
                                        );
                                },
                              );
                            },
                          ),
                          BlocBuilder<GameBloc, bool>(
                            builder: (ctx, gameState) {
                              return gameState
                                  ? Container(
                                      color: Colors.white,
                                      width: size.width * 0.08,
                                      height: size.width * 0.08,
                                      child: QrImage(
                                        padding:
                                            EdgeInsets.all(size.width * 0.002),
                                        data: games[imageAdIndexState],
                                        version: QrVersions.auto,
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 0,
                                      height: 0,
                                    );
                            },
                          ),
                        ],
                      );
                    },
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  );
          },
        ),
      ],
    );
  }

  Widget buildAdvertiseLandscape(Size size) {
    return Row(
      children: <Widget>[
        BlocBuilder<VideoBloc, bool>(
          builder: (context, videoState) {
            return videoState == true
                ? BlocBuilder<ControllerIndexBloc, int>(
                    builder: (context, controllerIndexState) {
                      return BlocBuilder<ImageBloc, bool>(
                        builder: (context, imageState) {
                          return imageState
                              ? SizedBox(
                                  width: size.width * 0.6,
                                  height: size.height * 9 / 16,
                                  child: VideoPlayer(
                                      controllers[controllerIndexState]),
                                )
                              : SizedBox(
                                  width: size.width,
                                  height: size.height,
                                  child: VideoPlayer(
                                      controllers[controllerIndexState]),
                                );
                        },
                      );
                    },
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  );
          },
        ),
        BlocBuilder<ImageBloc, bool>(
          builder: (context, imageState) {
            return imageState == true
                ? BlocBuilder<ImageAdIndexBloc, int>(
                    builder: (context, imageAdIndexState) {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          BlocBuilder<ImageIndexBloc, int>(
                            builder: (context, imageIndexState) {
                              return BlocBuilder<VideoBloc, bool>(
                                builder: (context, videoState) {
                                  return videoState
                                      ? SizedBox(
                                          width: size.width * 0.4,
                                          height: size.height,
                                          child: Image.file(
                                            File(
                                                '$dir/${images[imageAdIndexState][imageIndexState]}'),
                                          ),
                                        )
                                      : SizedBox(
                                          width: size.width,
                                          height: size.height,
                                          child: Image.file(
                                            File(
                                                '$dir/${images[imageAdIndexState][imageIndexState]}'),
                                          ),
                                        );
                                },
                              );
                            },
                          ),
                          BlocBuilder<GameBloc, bool>(
                            builder: (ctx, gameState) {
                              return gameState
                                  ? Container(
                                      color: Colors.white,
                                      width: size.width * 0.05,
                                      height: size.width * 0.05,
                                      child: QrImage(
                                        padding:
                                            EdgeInsets.all(size.width * 0.002),
                                        data: games[imageAdIndexState],
                                        version: QrVersions.auto,
                                      ),
                                    )
                                  : SizedBox(
                                      width: 0,
                                      height: 0,
                                    );
                            },
                          ),
                        ],
                      );
                    },
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FutureBuilder(
      future: initVideo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return BlocBuilder<AdvertiseBloc, bool>(
            builder: (context, advertiseState) {
              return advertiseState
                  ? isPortrait
                      ? buildAdvertisePortrait(size)
                      : buildAdvertiseLandscape(size)
                  : Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Không có quảng cáo nào đang chạy'),
                            SizedBox(height: size.height * 0.03),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                    AdvertisementScreen.routeName);
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
            },
          );
        else {
          return Container(
            height: size.height,
            width: size.width,
            color: Colors.blue,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: size.width * 0.6,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    timers.forEach((timer) => timer?.cancel());
    periodic?.cancel();
    imageCache.clear();
    controllers[0]?.dispose();
    controllers[1]?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
