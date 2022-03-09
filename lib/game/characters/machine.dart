import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:jumping_syllables/game/animation_helper.dart';
import 'package:jumping_syllables/game/models/machine/invisibletappable.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';
import 'package:jumping_syllables/game/models/cardpanel/card.dart' as cards;
import 'package:jumping_syllables/game/models/flyoutcube/flyoutcube.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';
import 'dart:io' show Platform;

class Machine extends SpriteAnimationComponent
    with HasGameRef<JSGame>, Tappable {
  Machine({
    required this.jsGame,
    required this.width,
    required this.height,
  }) : super(size: Vector2(width, height));

  int syllable = 0;
  List<FlyOutCube> flyOutCubeList = [];
  late SpriteAnimation standingAnimation;
  late SpriteAnimation workingAnimation;
  late SpriteAnimation firingAnimation;
  late InvisibleTappable invisibleTappable;
  final double width;
  final double height;
  final JSGame jsGame;
  MachineAnimationStatus machineAnimationStatus = MachineAnimationStatus.None;
  double timePlaying = 0;
  double boardOpacity = 1;
  double stickOpacity = 1;
  double placeHolderOpacity = 0;
  late Vector2 boardPosition;
  late Vector2 stickPosition;
  Vector2 scaleFactor = Vector2(1.0, 1.0);
  late Vector2 placeHolderBackPosition;
  late Vector2 placeHolderPosition;
  Vector2 defaultPlaceHolderPositionDelta = Vector2(15, 20);

  late Sprite boardBlock;
  late Sprite stickBlock;
  Sprite? placeHolderBlock;
  late Sprite placeHolderBackBlock;
  bool firingAnimationFinished = false;
  int firingCount = 0;
  String structure = "";

  @override
  Future<void> onLoad() async {
    super.onLoad();

    var stickImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'Stick-min.png');
    var boardImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'Placeholder-min.png');
    var pBackImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + "Card_Base.png");
    stickBlock = Sprite(stickImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(78, 292));
    boardBlock = Sprite(boardImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(516, 482));
    placeHolderBackBlock = Sprite(pBackImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(474, 443));

    resetPosition();

    invisibleTappable = InvisibleTappable(jsGame: jsGame);
    invisibleTappable.position = placeHolderBackPosition.clone();
    invisibleTappable.size =
        Vector2(130 * jsGame.widthRatio, 130 * jsGame.widthRatio);

    add(invisibleTappable);

    await loadAnimations();
    animation = standingAnimation;
  }

  void setSize(double sizeWidth, double sizeHeight) {
    size = Vector2(sizeWidth, sizeHeight);
  }

  void clearFlyOutCubes() {
    for (int i = 0; i < flyOutCubeList.length; ++i) {
      remove(flyOutCubeList[i]);
    }
    flyOutCubeList.clear();
  }

  void hidePlaceHolder() {
    timePlaying = 0;
    machineAnimationStatus = MachineAnimationStatus.PlaceHolderHidingStatus;
  }

  void moveLeftMachine() {
    timePlaying = 0;
    machineAnimationStatus = MachineAnimationStatus.MoveLeftMore;
  }

  @override
  void render(Canvas canvas) {
    Paint stickOpacityPaint = Paint()
      ..color = Colors.white.withOpacity(stickOpacity);
    stickBlock.renderRect(
        canvas,
        Rect.fromLTWH(
          stickPosition.x,
          stickPosition.y,
          20 * jsGame.widthRatio,
          80 * jsGame.widthRatio,
        ),
        overridePaint: stickOpacityPaint);

    Paint boardOpacityPaint = Paint()
      ..color = Colors.white.withOpacity(boardOpacity);
    boardBlock.renderRect(
        canvas,
        Rect.fromLTWH(
          stickPosition.x - (55 - 5) * jsGame.widthRatio,
          stickPosition.y - 120 * jsGame.widthRatio + 5,
          120 * jsGame.widthRatio,
          120 * jsGame.widthRatio,
        ),
        overridePaint: boardOpacityPaint);

    Paint placeHolderOpacityPaint = Paint()
      ..color = Colors.white.withOpacity(placeHolderOpacity);
    if (syllable != 0) {
      // This means place holder card added
      placeHolderBackBlock.renderRect(
          canvas,
          Rect.fromLTWH(
            stickPosition.x -
                (55 - 5) * jsGame.widthRatio -
                120 * jsGame.widthRatio * (scaleFactor.x - 1) / 2,
            stickPosition.y -
                120 * jsGame.widthRatio -
                120 * jsGame.widthRatio * (scaleFactor.y - 1) / 2 +
                5,
            120 * jsGame.widthRatio * scaleFactor.x,
            120 * jsGame.widthRatio * scaleFactor.y,
          ),
          overridePaint: placeHolderOpacityPaint);
      placeHolderBlock?.renderRect(
          canvas,
          Rect.fromLTWH(
            stickPosition.x -
                (55 - 5) * jsGame.widthRatio -
                120 * jsGame.widthRatio * (scaleFactor.x - 1) / 2 +
                17.5 * jsGame.widthRatio +
                85 * jsGame.widthRatio * (scaleFactor.x - 1) / 2,
            stickPosition.y -
                120 * jsGame.widthRatio -
                120 * jsGame.widthRatio * (scaleFactor.y - 1) / 2 +
                17.5 * jsGame.widthRatio +
                85 * jsGame.widthRatio * (scaleFactor.y - 1) / 2 +
                5,
            85 * jsGame.widthRatio * scaleFactor.x,
            85 * jsGame.widthRatio * scaleFactor.y,
          ),
          overridePaint: placeHolderOpacityPaint);
    }
    super.render(canvas);
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (machineAnimationStatus == MachineAnimationStatus.None) {
    } else if (machineAnimationStatus ==
        MachineAnimationStatus.NotifyWithZoom) {
      timePlaying += delta;

      for (int i = 0; i < syllable; ++i) {
        if (timePlaying >= 0.7 * i && timePlaying < 0.7 * i + 0.35) {
          scaleFactor.x = animationHelper.calculateLimit(
              scaleFactor.x + 0.5 * delta, 1.175, true);
          scaleFactor.y = animationHelper.calculateLimit(
              scaleFactor.y + 0.5 * delta, 1.175, true);
        } else if (timePlaying >= 0.7 * i + 0.35 &&
            timePlaying < 0.7 * i + 0.7) {
          scaleFactor.x = animationHelper.calculateLimit(
              scaleFactor.x - 0.5 * delta, 1, false);
          scaleFactor.y = animationHelper.calculateLimit(
              scaleFactor.y - 0.5 * delta, 1, false);
        }
      }

      if (timePlaying >= 0 && timePlaying < 0.7 * syllable + 0.35) {
      } else if (timePlaying >= 0.7 * syllable + 0.35 &&
          timePlaying < 0.7 * syllable + 0.7) {
        scaleFactor = Vector2(1, 1);
        // Delay here for MachineInput hides
      } else {}
    } else if (machineAnimationStatus ==
        MachineAnimationStatus.PlaceHolderHidingStatus) {
      timePlaying += delta;
      if (timePlaying >= 0 && timePlaying < 0.5) {
        double downwardMovingDistance = timePlaying * 500 + 50;
        boardPosition.add(Vector2(0, downwardMovingDistance * delta));
        stickPosition.add(Vector2(0, downwardMovingDistance * delta));
        boardOpacity = 0;
        placeHolderOpacity = (placeHolderOpacity - 0.1 * delta) < 0
            ? 0
            : (placeHolderOpacity - 0.1 * delta);
        placeHolderPosition.add(Vector2(0, downwardMovingDistance * delta));
        placeHolderBackPosition.add(Vector2(0, downwardMovingDistance * delta));
      } else {
        boardOpacity = 0;
        stickOpacity = 0;
        placeHolderOpacity = 0;
        boardPosition =
            Vector2(190 * jsGame.widthRatio, 100 + 140 * jsGame.widthRatio) +
                defaultPlaceHolderPositionDelta;
        stickPosition =
            Vector2(130 * jsGame.widthRatio, 100 + -30 * jsGame.widthRatio) +
                defaultPlaceHolderPositionDelta;
        placeHolderPosition = Vector2(90 + 80 * jsGame.widthRatio, -20 + 100) +
            defaultPlaceHolderPositionDelta;
        placeHolderBackPosition =
            Vector2(130, -60 + 100) + defaultPlaceHolderPositionDelta;
        machineAnimationStatus = MachineAnimationStatus.None;
        startWorking();
      }
    } else if (machineAnimationStatus == MachineAnimationStatus.PumpOutStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == 0 && animation == firingAnimation) {
        firingAnimationFinished = false;
      }
      if (animation!.currentIndex == 5) {
        if (firingAnimationFinished == false && animation == firingAnimation) {
          firingAnimationFinished = true;
          flyOutCubeList[firingCount].flyOutCube();
          firingCount++;
          jsGame.jsAudioManager.playUISound("Machine-firing.mp3");
        }
      }
      if (animation!.currentIndex == firingAnimation.frames.length - 1) {
        if (firingCount == syllable) {
          if (firingAnimationFinished == true) {
            print("[DEBUG] - setting back to standing is: " +
                flyOutCubeList.length.toString() +
                ", " +
                firingCount.toString());
            animation = standingAnimation;
            timePlaying = 0;
            firingCount = 0;
            firingAnimationFinished = false;
            machineAnimationStatus = MachineAnimationStatus.None;

            jsGame.gameUtil.delayer
                .wait(
                  milliseconds: 500,
                  run: () async {
                    removeFlyoutCubesFromStage();

                    jsGame.fadeSlide.afterFadeOutCall = () {
                      position -= Vector2(1000, 0);
                      jsGame.setJumpStage();

                      double backgroundMovableDistance =
                          jsGame.animationBackground.size.x +
                              jsGame.animationBackground.position.x;
                      jsGame.animationBackground.position.x -=
                          backgroundMovableDistance;

                      if (jsGame.wordStep % 3 == 0) {
                        jsGame.jsAudioManager
                            .shoutWJ("WJ_Read-after-us-jump-with-us.mp3");

                        jsGame.joy.askQuestion();
                        jsGame.woof.askQuestion();

                        jsGame.gameUtil.delayer
                            .wait(
                              seconds: 4,
                              run: () async {
                                jsGame.startSyllablePronunciation();
                              },
                            )
                            .catchError((_) {});
                      } else {
                        jsGame.startSyllablePronunciation();
                      }
                    };
                    jsGame.fadeSlide.fadeOut();
                  },
                )
                .catchError((_) {});
          }
        }
      }
    } else if (machineAnimationStatus == MachineAnimationStatus.MoveLeftMore) {
      timePlaying += delta;
      if (timePlaying >= 0 && timePlaying < 0.2) {
        position += Vector2(-2000 * delta, 0);
        for (int i = 0; i < flyOutCubeList.length; ++i) {
          flyOutCubeList[i].position += Vector2(2000 * delta, 0);
        }
      } else {
        timePlaying = 0;
        machineAnimationStatus = MachineAnimationStatus.None;
      }
    } else {
      machineAnimationStatus = MachineAnimationStatus.None;
      timePlaying = 0;
    }
  }

  void removeFlyoutCubesFromStage() {
    for (int i = 0; i < flyOutCubeList.length; ++i) {
      flyOutCubeList[i].position.x += jsGame.size.x * 2;
    }
    clearFlyOutCubes();
  }

  void resetPosition() {
    if (Platform.isIOS) {
      stickPosition =
          Vector2(width / 2.00, position.y - 75 * jsGame.heightRatio);
    } else {
      stickPosition =
          Vector2(width / 2.00, position.y - 80 * jsGame.heightRatio);
    }

    boardPosition = Vector2(stickPosition.x - (60 - 5) * jsGame.widthRatio,
        stickPosition.y - 130 * jsGame.widthRatio + 5);
    placeHolderBackPosition = Vector2(
        stickPosition.x - (60 - 5) * jsGame.widthRatio,
        stickPosition.y - 130 * jsGame.widthRatio + 5);
    placeHolderPosition = placeHolderBackPosition +
        Vector2(20 * jsGame.widthRatio, 20 * jsGame.widthRatio + 5);
  }

  void resetMachine() {
    resetPosition();
    boardOpacity = 1;
    stickOpacity = 1;
    placeHolderOpacity = 0;
    animation = standingAnimation;
    machineAnimationStatus = MachineAnimationStatus.None;
    syllable = 0;

    removeFlyoutCubesFromStage();
  }

  Future<void> setPlaceHolderImage(String text) async {
    var cardImage = await jsGame.gameUtil.assetManager.loadUiImage(
        'images/' + syllable.toString() + '_syllable/' + text + '.png');
    placeHolderBlock = Sprite(cardImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(476, 431));
  }

  void addCard(cards.Card remCard) {
    syllable = remCard.syllable;
    setPlaceHolderImage(remCard.text);
    placeHolderOpacity = 1;
    boardOpacity = 0;
    structure = remCard.structure;

    jsGame.jsAudioManager.playUISound("Card-drop.mp3");

    List<String> structureList = remCard.structure.split("-");
    for (int i = 0; i < structureList.length; ++i) {
      flyOutCubeList.add(
        FlyOutCube(
          text: structureList[i],
          gameUtil: gameRef.gameUtil,
        ),
      );
      flyOutCubeList[i].initCube().then((value) => {
            flyOutCubeList[i].setParameters(1, 80, 80, i + 1),
            flyOutCubeList[i].position = Vector2(350 - jsGame.size.x * 2, 90),
            add(flyOutCubeList[i]),
          });
    }
  }

  void startWorking() {
    timePlaying = 0;
    animation = workingAnimation;
    jsGame.jsAudioManager.playUISound("Syllable-machine-working.mp3");
  }

  void startFiring() {
    animation = firingAnimation;
    machineAnimationStatus = MachineAnimationStatus.PumpOutStatus;
    animation?.onComplete = () {
      print("[DEBUG] - firing animation completed");
    };
  }

  void hideMachineInput() {
    machineAnimationStatus = MachineAnimationStatus.NotifyWithZoom;
    timePlaying = 0;
  }

  Future<void> loadAnimations() async {
    var tempMachineImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + "animations/machine/machine-working.png");
    var ratio = 6960 / tempMachineImage.width;

    final sprites = [0, 1, 2, 3, 4, 5].map((i) => Sprite(tempMachineImage,
        srcPosition: Vector2(i * 1160 / ratio, 0),
        srcSize: Vector2(1160 / ratio, 728 / ratio)));

    workingAnimation =
        SpriteAnimation.spriteList(sprites.toList(), stepTime: 0.15);
    standingAnimation = SpriteAnimation.spriteList(
        sprites.toList().sublist(0, 1),
        stepTime: 0.15);

    var firingMachineImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + "animations/machine/machine-firing.png");

    final spriteSheet2 = SpriteSheet(
      image: firingMachineImage,
      srcSize: Vector2(1160.0 / (10440 / firingMachineImage.width),
          728.0 / (728 / firingMachineImage.height)),
    );
    firingAnimation =
        spriteSheet2.createAnimation(row: 0, stepTime: 0.095, to: 9);
  }
}
