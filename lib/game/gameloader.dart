import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:common/common.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:jumping_syllables/game/constants/enumerations.dart';
import 'package:jumping_syllables/game/helpers/urlvideomanager.dart';
import 'package:jumping_syllables/game/helpers/videomanager.dart';
import 'package:jumping_syllables/game/helpers/videourl.dart';
import 'package:jumping_syllables/game/statenotifiers/flagindexprovider.dart';

import 'screens/jsgame.dart';

final splashVideoFlag = StateProvider.autoDispose((ref) => false);

final outroVideoFlag = ChangeNotifierProvider.autoDispose((_) {
  return URLVideoState();
});

class JumpingSyllablesGame extends FabGameWidget {
  JumpingSyllablesGame({
    required BundleAsset bundleAsset,
    required VoidCallback onStart,
    required VoidCallback onEnd,
    required VoidCallback onClose,
    required Future<String> bonusCardVideoUrlLoader,
  }) : super(
          bundleAsset: bundleAsset,
          onStart: onStart,
          onEnd: onEnd,
          onClose: onClose,
          bonusCardVideoUrlLoader: bonusCardVideoUrlLoader,
        );

  @override
  FabGameWidgetState<FabGameWidget> createState() =>
      _JumpingSyllablesGameState();
}

class _JumpingSyllablesGameState
    extends FabGameWidgetState<JumpingSyllablesGame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GameLoader(
        gameUtil: gameUtil,
      ),
    );
  }
}

class GameLoader extends StatefulWidget {
  GameLoader({
    required this.gameUtil,
  });

  final GameUtil gameUtil;

  @override
  _GameLoaderState createState() => _GameLoaderState();
}

class _GameLoaderState extends State<GameLoader> with TickerProviderStateMixin {
  late AnimationController fadeController;
  late final AnimationController rotationController = AnimationController(
    duration: const Duration(seconds: 20),
    // This duration must be bigger than the animation play time
    vsync: this,
  )..forward(from: 0);
  late final CurvedAnimation rotationAnimation =
      CurvedAnimation(parent: rotationController, curve: Curves.easeInExpo);
  late final game;
  late Future<VideoURL> videoURL;
  Uint8List thumbnailBytes = Uint8List(0);
  ByteData imageData = ByteData(0);

  @override
  void initState() {
    widget.gameUtil.onStart();
    PROVIDER_CONTAINER.read(splashVideoFlag).state = false;
    PROVIDER_CONTAINER.read(outroVideoFlag).initFlag();

    game = JSGame(gameUtil: widget.gameUtil);
    videoURL = getVideoFromBE();
    fadeController = new AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addListener(() {
        if (fadeController.isCompleted) {
          print("[DEBUG] - animation finished");
          widget.gameUtil.delayer
              .wait(
                milliseconds: 500,
                run: () async {
                  game
                      .fadeOutSplashStart()
                      .then((value) => {game.overlays.remove("Splash-Video")});
                },
              )
              .catchError((_) {});
        }
      });
    super.initState();
    // WidgetsBinding.instance!.addObserver(this);
  }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance!.removeObserver(this);
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   print("[DEBUG] - life cycle test: " + state.toString());
  //   super.didChangeAppLifecycleState(state);
  //
  //   if (state == AppLifecycleState.resumed) {
  //     game.jsAudioManager.stopBGM();
  //
  //     if (game.stageStatus != StageStatus.OutroStage &&
  //         game.stageStatus != StageStatus.SplashStage) {
  //       game.jsAudioManager.playBackgroundMusic();
  //     }
  //   } else {
  //     game.jsAudioManager.stopBGM();
  //   }
  // }

  Future<VideoURL> getVideoFromBE() async {
    final response = await http
        .get(Uri.parse("https://api.edu.hedgefun.net/learning/bonusCard"));
    if (response.statusCode == 200) {
      return VideoURL.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    VideoPlayManager splashPlayerScreen = VideoPlayManager(
      parameterVideo: 'splash',
      parameterWidth: width,
      parameterHeight: width * 3 / 4,
      gameUtil: widget.gameUtil,
    );

    VideoPlayManager introPlayerScreen = VideoPlayManager(
      parameterVideo: 'intro',
      parameterWidth: width,
      parameterHeight: width * 3 / 4,
      gameUtil: widget.gameUtil,
    );

    URLVideoPlayManager? urlVideoPlayerScreen;

    videoURL.then(
      (value) async {
        print("[DEBUG] - video URL loaded successfully");
        imageData = await NetworkAssetBundle(
          Uri.parse(value.thumbnail),
        ).load("");
        thumbnailBytes = imageData.buffer.asUint8List();
        urlVideoPlayerScreen = URLVideoPlayManager(
          parameterWidth: width / 2.2,
          parameterHeight: width / 4,
          videoURL: value.url,
          thumbnailURL: value.thumbnail,
          thumbnailBytes: thumbnailBytes,
          gameUtil: widget.gameUtil,
        );
      },
    );

    return Consumer(
      builder: (ctx, watch, child) {
        final splashStateController = watch(splashVideoFlag);
        final outroStateController = watch(outroVideoFlag);
        return Container(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: GameWidget<JSGame>(
                  game: game,
                  loadingBuilder: (ctx) => Center(
                    child: OverflowBox(
                      maxWidth: width,
                      maxHeight: height,
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: Container(
                          child: Image.file(
                            widget.gameUtil.assetManager
                                .file("images/Splash.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  overlayBuilderMap: {
                    'Splash-Video': (ctx, none) {
                      if (splashStateController.state) {
                        fadeController.forward(from: 0);
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: splashPlayerScreen,
                          ),
                          AnimatedBuilder(
                            animation: fadeController,
                            builder: (_, child) {
                              return Opacity(
                                opacity: splashStateController.state
                                    ? fadeController.value
                                    : 0,
                                child: Container(
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    'Intro-Video': (ctx, none) {
                      return Center(
                        child: introPlayerScreen,
                      );
                    },
                    'Outro-Video': (ctx, none) {
                      return GestureDetector(
                        onTap: () {
                          if (game.stageStatus == StageStatus.OutroStage &&
                              game.outroFinish) {
                            outroStateController.setVideoRepeatFlag(true);
                          }
                        },
                        child: AnimatedBuilder(
                            animation: rotationAnimation,
                            child: Center(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Center(
                                    child: urlVideoPlayerScreen,
                                  ),
                                  Positioned(
                                    top: (height - width / 3) / 2,
                                    left: (width - width / 1.7) / 2,
                                    width: width / 1.7,
                                    height: width / 3,
                                    child: Image.file(
                                      widget.gameUtil.assetManager
                                          .file("images/Outro-cardbase.png"),
                                    ),
                                  ),
                                  Positioned(
                                    top: (height - width / 3) / 2 +
                                        width / 3 / 4.5,
                                    left: (width - width / 1.7) / 2 +
                                        width / 1.7 / 1.375,
                                    width: 34.0 * game.widthRatio,
                                    height: 34.0 * game.widthRatio,
                                    child: Image.file(
                                      widget.gameUtil.assetManager.file(
                                        "images/Video-tap.png",
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    width: width / 2.3,
                                    height: height / 5.5,
                                    top: height / 3 + width / 5.5 + height / 35,
                                    left: (width - width / 2.3) / 2,
                                    child: outroStateController.flag
                                        ? GestureDetector(
                                            child: Image.file(
                                              widget.gameUtil.assetManager.file(
                                                "images/Next-button.png",
                                              ),
                                            ),
                                            onTap: () {
                                              widget.gameUtil.onEnd();
                                            },
                                          )
                                        : Container(),
                                  ),
                                ],
                              ),
                            ),
                            builder: (BuildContext ctx, Widget? child) {
                              double delayedRotationValue = () {
                                if (rotationController.value < 0.025)
                                  return rotationController.value * 40;
                                return 1.0;
                              }();

                              double animationScale = () {
                                if (outroStateController.flag) {
                                  if (outroStateController.scaleEffectCount ==
                                      0.0)
                                    outroStateController.scaleEffectCount =
                                        rotationController.value;
                                  if (rotationController.value -
                                          outroStateController
                                              .scaleEffectCount <
                                      15 / 256) {
                                    return outroStateController
                                            .lastScaleEffectValue =
                                        1 +
                                            sin(64 *
                                                    pi *
                                                    rotationController.value) /
                                                40;
                                  }
                                  return outroStateController
                                      .lastScaleEffectValue;
                                }
                                return 2.0 - 1.0 * delayedRotationValue;
                              }();

                              return Transform.rotate(
                                angle: (0.15 - delayedRotationValue * 0.15) *
                                    2.0 *
                                    pi,
                                child: Transform.translate(
                                  offset: Offset(50 - delayedRotationValue * 50,
                                      50 - delayedRotationValue * 50),
                                  child: Transform.scale(
                                    scale: animationScale,
                                    child: child,
                                  ),
                                ),
                              );
                            }),
                      );
                    }
                  },
                  initialActiveOverlays: [],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
