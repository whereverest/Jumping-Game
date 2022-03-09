import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class Joy extends SpriteAnimationComponent with HasGameRef, Tappable {
  final JSGame jsGame;

  Joy({
    required this.jsGame,
    required this.width,
    required this.height,
  }) : super(size: Vector2(width, height));

  late final SpriteAnimation waitingAnimation;
  late final SpriteAnimation clappingAnimation;
  late final SpriteAnimation justClappingAnimation;
  late final SpriteAnimation wonderfulJumpingAnimation;
  late final SpriteAnimation laughingAnimation;
  late final SpriteAnimation speakingAnimation;
  final double width;
  final double height;
  double timePlaying = 0;
  JoyStatus joyStatus = JoyStatus.None;
  int currentJumpIndex = 0;
  int clappingCount = 0;
  int simpleClappingCount = 0;
  bool settingClappingFlag = false;
  bool simpleClapAndSayAudibleFlag = true;

  @override
  bool onTapUp(TapUpInfo info) {
    double x = info.eventPosition.global.x;
    double y = info.eventPosition.global.y;

    if (jsGame.stageStatus == StageStatus.SetStage &&
        jsGame.machine.placeHolderOpacity == 1) {
      if (x >= position.x &&
          x < position.x + size.x &&
          y >= position.y &&
          y < position.y + size.y) {
        if (jsGame.machine.syllable != 0) {
          if (jsGame.joyAudioList.contains(jsGame.machine.structure)) {
            jsGame.joy.simpleClapAndSay(true);
            jsGame.woof.simpleClapAndSay(false);
          }
          if (jsGame.woofAudioList.contains(jsGame.machine.structure)) {
            jsGame.joy.simpleClapAndSay(false);
            jsGame.woof.simpleClapAndSay(true);
          }
        }
      }
    }

    return super.onTapUp(info);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    animation = waitingAnimation;
  }

  void setSize(double sizeWidth, double sizeHeight) {
    size = Vector2(sizeWidth, sizeHeight);
  }

  void reset() {
    joyStatus = JoyStatus.None;
    animation = waitingAnimation;
    animation!.currentIndex = 0;
    timePlaying = 0;
    settingClappingFlag = false;
    simpleClapAndSayAudibleFlag = true;
    simpleClappingCount = 0;
    clappingCount = 0;
  }

  void laugh() {
    timePlaying = 0;
    animation = laughingAnimation;
    animation!.currentIndex = 0;
    joyStatus = JoyStatus.LaughingStatus;
  }

  void jump() {
    timePlaying = 0;
    animation = wonderfulJumpingAnimation;
    animation!.currentIndex = 0;
    joyStatus = JoyStatus.SyllablePronunciationStatus;
  }

  void speak() {
    animation = speakingAnimation;
    animation!.currentIndex = 0;
    joyStatus = JoyStatus.SpeakingStatus;
  }

  void askQuestion() {
    animation = speakingAnimation;
    animation!.currentIndex = 0;
    joyStatus = JoyStatus.AskingStatus;
  }

  void startJustClapping() {
    animation = justClappingAnimation;
    animation!.currentIndex = 0;
    settingClappingFlag = true;
    joyStatus = JoyStatus.ClappingStatus;
  }

  void startClappingAndSpeaking() {
    animation = clappingAnimation;
    animation!.currentIndex = 0;
    settingClappingFlag = true;
    joyStatus = JoyStatus.ClappingStatus;
  }

  void simpleClapAndSay(bool isJoyWord, {isAudible: true, syllableCount: 1}) {
    if (isJoyWord) {
      animation = clappingAnimation;
    } else {
      animation = justClappingAnimation;
    }
    simpleClapAndSayAudibleFlag = isAudible;

    if (!simpleClapAndSayAudibleFlag) simpleClappingCount = syllableCount;

    jsGame.jsAudioManager.stopSpeaking();
    animation!.currentIndex = 0;
    settingClappingFlag = true;
    joyStatus = JoyStatus.SimpleClapAndSayStatus;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (joyStatus == JoyStatus.None) {
      animation = waitingAnimation;
    } else if (joyStatus == JoyStatus.AskingStatus) {
      timePlaying += delta;

      if (timePlaying >= 0 && timePlaying < 4) {
      } else {
        animation = waitingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        joyStatus = JoyStatus.None;
      }
    } else if (joyStatus == JoyStatus.SpeakingStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == animation!.frames.length - 1) {
        animation = waitingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        joyStatus = JoyStatus.None;
      }
    } else if (joyStatus == JoyStatus.SimpleClapAndSayStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == 0) {
        if (simpleClapAndSayAudibleFlag) {
          if (jsGame.machine.syllable == 1) {
            if (clappingCount == 0) {
              if (jsGame.joyAudioList.contains(jsGame.machine.structure)) {
                if (settingClappingFlag == true) {
                  jsGame.jsAudioManager
                      .sayWord("JOY", jsGame.machine.structure);
                }
              }
            }
          } else {
            if (jsGame.joyAudioList.contains(jsGame.machine.structure)) {
              if (settingClappingFlag == true) {
                ///
                /// TODO It's a very bad solution. The same sounds will be called a few times
                ///
                jsGame.jsAudioManager.saySeparated(
                    "JOY",
                    jsGame.machine.structure +
                        "_0" +
                        (clappingCount + 1).toString());
              }
            }
          }
        }

        settingClappingFlag = false;
      }
      if (animation!.currentIndex == animation!.frames.length - 1) {
        if (settingClappingFlag == false) {
          settingClappingFlag = true;
          clappingCount++;
        }
      }

      if (simpleClapAndSayAudibleFlag) {
        simpleClappingCount = 0;
        if (jsGame.machine.syllable == 0) {
          // Card is not placed in the place holder in machine
          simpleClappingCount = 1;
        } else {
          simpleClappingCount = jsGame.machine.syllable;
        }
      }

      if (clappingCount == simpleClappingCount) {
        animation = waitingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        clappingCount = 0;
        simpleClappingCount = 0;
        settingClappingFlag = false;
        simpleClapAndSayAudibleFlag = true;
        joyStatus = JoyStatus.None;
      }
    } else if (joyStatus == JoyStatus.ClappingStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == 0) {
        if (jsGame.machine.syllable == 1) {
          if (clappingCount == 0) {
            if (jsGame.joyAudioList.contains(jsGame.machine.structure)) {
              if (settingClappingFlag == true) {
                jsGame.jsAudioManager.sayWord("JOY", jsGame.machine.structure);
              }
            }
          }
        } else {
          if (jsGame.joyAudioList.contains(jsGame.machine.structure)) {
            if (settingClappingFlag == true) {
              ///
              /// TODO It's a very bad solution. The same sounds will be called a few times
              ///
              jsGame.jsAudioManager.saySeparated(
                  "JOY",
                  jsGame.machine.structure +
                      "_0" +
                      (clappingCount + 1).toString());
            }
          }
        }

        settingClappingFlag = false;
      }
      if (animation!.currentIndex == animation!.frames.length - 1) {
        if (settingClappingFlag == false) {
          clappingCount++;
          settingClappingFlag = true;
        }
      }
      if (clappingCount == jsGame.machine.syllable) {
        animation = wonderfulJumpingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        clappingCount = 0;
        settingClappingFlag = false;
        joyStatus = JoyStatus.JumpingStatus;

        jsGame.gameUtil.delayer
            .wait(
              milliseconds: 100,
              run: () async {
                var now = new DateTime.now();
                Random random = new Random(now.millisecondsSinceEpoch);

                jsGame.jsAudioManager
                    .sayRight("JOY", (random.nextInt(20) % 13 + 1).toString());
              },
            )
            .catchError((_) {});
      }
    } else if (joyStatus == JoyStatus.SyllablePronunciationStatus) {
      timePlaying += delta;

      if (animation!.currentIndex ==
          wonderfulJumpingAnimation.frames.length - 1) {
        animation = waitingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        joyStatus = JoyStatus.None;
      }
    } else if (joyStatus == JoyStatus.JumpingStatus) {
      timePlaying += delta;

      if (animation!.currentIndex ==
          wonderfulJumpingAnimation.frames.length - 1) {
        if (animation == wonderfulJumpingAnimation) {
          timePlaying = 0;
          joyStatus = JoyStatus.None;
          animation = waitingAnimation;
          animation!.currentIndex = 0;
          jsGame.machine.hidePlaceHolder();
          jsGame.syllablePanel
              .moveRightLinearParticular(jsGame.machine.syllable);

          jsGame.gameUtil.delayer
              .wait(
                seconds: 1,
                run: () async {
                  jsGame.flyBoxStage();
                },
              )
              .catchError((_) {});
        }
      }
    } else if (joyStatus == JoyStatus.LaughingStatus) {
    } else {
      animation = waitingAnimation;
    }
  }

  Future<void> loadAnimations() async {
    var standingJoyImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/joy/joy-basic-standing.png');
    var spriteSheet = SpriteSheet(
      image: standingJoyImage,
      srcSize: Vector2(512.0 / (3584 / standingJoyImage.width),
          512.0 / (512 / standingJoyImage.height)),
    );
    waitingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.2, to: 7);

    var speakingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/joy/joy-speaking.png');
    var spriteSheet2 = SpriteSheet(
      image: speakingAnimationImage,
      srcSize: Vector2(512.0 / (3584 / speakingAnimationImage.width),
          512.0 / (512 / speakingAnimationImage.height)),
    );
    speakingAnimation =
        spriteSheet2.createAnimation(row: 0, stepTime: 0.2, to: 7);

    var clappingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/joy/joy-clapping.png');
    var spriteSheet4 = SpriteSheet(
      image: clappingAnimationImage,
      srcSize: Vector2(512.0 / (3584 / clappingAnimationImage.width),
          512.0 / (512 / clappingAnimationImage.height)),
    );
    clappingAnimation =
        spriteSheet4.createAnimation(row: 0, stepTime: 0.1, to: 7);

    var justClappingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/joy/joy-just-clapping.png');
    var spriteSheet7 = SpriteSheet(
      image: justClappingAnimationImage,
      srcSize: Vector2(512.0 / (3584 / justClappingAnimationImage.width),
          512.0 / (512 / justClappingAnimationImage.height)),
    );
    justClappingAnimation =
        spriteSheet7.createAnimation(row: 0, stepTime: 0.1, to: 7);

    var wonderfulJumpingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/joy/joy-wonderful-jumping.png');
    var spriteSheet5 = SpriteSheet(
      image: wonderfulJumpingAnimationImage,
      srcSize: Vector2(1024.0 / (10240 / wonderfulJumpingAnimationImage.width),
          1024.0 / (1024 / wonderfulJumpingAnimationImage.height)),
    );
    wonderfulJumpingAnimation =
        spriteSheet5.createAnimation(row: 0, stepTime: 0.15, to: 10);

    var laughingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/joy/joy-laughing.png');
    var spriteSheet6 = SpriteSheet(
      image: laughingAnimationImage,
      srcSize: Vector2(1024.0 / (13312 / laughingAnimationImage.width),
          1024.0 / (1024 / laughingAnimationImage.height)),
    );
    laughingAnimation =
        spriteSheet6.createAnimation(row: 0, stepTime: 0.1, to: 13);
  }
}
