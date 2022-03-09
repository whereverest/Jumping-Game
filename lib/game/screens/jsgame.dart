import 'dart:io' show Platform;
import 'dart:math';
// import 'dart:async' as dartAsync;

import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:jumping_syllables/game/animation_helper.dart';
import 'package:jumping_syllables/game/characters/joy.dart';
import 'package:jumping_syllables/game/characters/machine.dart';
import 'package:jumping_syllables/game/characters/microphone.dart';
import 'package:jumping_syllables/game/characters/outrofireworks.dart';
import 'package:jumping_syllables/game/characters/woof.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';
import 'package:jumping_syllables/game/helpers/jsaudiomanager.dart';
import 'package:jumping_syllables/game/models/cardpanel/card.dart' as JSCard;
import 'package:jumping_syllables/game/models/cardpanel/cardpanel.dart';
import 'package:jumping_syllables/game/models/flyoutcube/flyoutcube.dart';
import 'package:jumping_syllables/game/models/hand/hand.dart';
import 'package:jumping_syllables/game/models/splash/splash.dart';
import 'package:jumping_syllables/game/models/syllablepanel/syllablebutton.dart';
import 'package:jumping_syllables/game/models/syllablepanel/syllablepanel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animationbackground.dart';
import 'background.dart';
import 'fadeslide.dart';

class JSGame extends FlameGame with HasDraggables, HasTappables {
  JSGame({
    required this.gameUtil,
  });

  final GameUtil gameUtil;

  //////////////////// Variables ////////////////////////

  late Joy joy;
  late Woof woof;
  late CardPanel cardPanel;
  late Microphone microphone;
  late Machine machine;
  late Hand hand;
  late Splash splash;
  late OutroFireWorks outroFireworks;
  late FadeSlide fadeSlide;
  late SyllablePanel syllablePanel;
  late int wordStep;
  late int hoorayCount;
  late bool outroFinish;
  late TimerComponent timerComponent;

  // late dartAsync.Timer clappingTimer, syllableButtonTimer;
  late Background background;
  late AnimationBackground animationBackground;
  bool isFirstRun = true;
  bool syllablePronunciationFlag = false;
  List<JSCard.Card> giftCardList = [];
  List<SyllableButton> giftSyllableButtonList = [];

  double timePlaying = 0.0;
  StageStatus stageStatus = StageStatus.None;
  double widthRatio = 0.0;
  double heightRatio = 0.0;

  late JSAudioManager jsAudioManager = JSAudioManager(gameUtil: gameUtil);
  List<String> joyAudioList = [];
  List<String> woofAudioList = [];

  Future<void> preloadAudioAssets() async {
    joyAudioList = [
      "bag",
      "bed",
      "bun",
      "com-pu-ter",
      "di-no-saur",
      "el-e-phant",
      "e-lev-en",
      "jack-et",
      "lock",
      "mi-cro-phone",
      "mon-key",
      "owl",
      "pi-a-no",
      "pic-ture",
      "rab-bit",
      "ro-bin",
      "six",
      "star",
      "sun",
      "tree",
      "win-dow"
    ];
    woofAudioList = [
      "ba-na-na",
      "bear",
      "but-ter-fly",
      "cloud",
      "cob-web",
      "co-co-nut",
      "dog",
      "fox",
      "hat",
      "hen",
      "kan-ga-roo",
      "li-on",
      "mat",
      "mouse",
      "oc-to-pus",
      "pan-da",
      "pic-nic",
      "po-ta-to",
      "rock-et",
      "tick-et",
      "to-ma-to"
    ];
  }

  Future<void> fadeOutSplashStart() async {
    await add(splash);
    jsAudioManager.stopBGM();
    jsAudioManager.playBackgroundMusic();
    timePlaying = 0;
    stageStatus = StageStatus.BeforeStage;
  }

  @override
  void onRemove() {
    print("[DEBUG] - onRemove -- jsGame.dart");
    jsAudioManager.clearOut();
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstRun = (prefs.getBool('GlobalIsFirstRunFlag') ?? true);

    if (isFirstRun) {
      await prefs.setBool('GlobalIsFirstRunFlag', true);
    }

    overlays.add('Splash-Video');
    await preloadAudioAssets();

    wordStep = 8;
    hoorayCount = 0;
    outroFinish = false;

    widthRatio = size.x / 750;
    heightRatio = size.y / 580.25;

    joy = Joy(
      jsGame: this,
      width: 221.78 * widthRatio,
      height: 221.78 * widthRatio,
    );
    woof = Woof(
      jsGame: this,
      width: 237.26 * widthRatio,
      height: 237.36 * widthRatio,
    );
    splash = Splash(
      width: size.x,
      height: size.y,
    );
    machine = Machine(
      jsGame: this,
      width: 326.58 * widthRatio,
      height: 326.71 * widthRatio,
    );
    fadeSlide = FadeSlide(
      jsGame: this,
      width: size.x * 3,
      height: size.y,
    );
    cardPanel = CardPanel(
      jsGame: this,
      width: 150,
      height: size.y,
    );
    background = Background(
      width: size.x,
      height: size.y,
      gameUtil: gameUtil,
    );
    microphone = Microphone(
      width: 50.5 * widthRatio,
      height: 136.07 * widthRatio,
      gameUtil: gameUtil,
    );
    syllablePanel = SyllablePanel(
      jsGame: this,
      width: 150,
      height: size.y,
    );
    outroFireworks = OutroFireWorks(
      width: size.y,
      height: size.y,
      gameUtil: gameUtil,
    );

    joy.position = Vector2(-size.x * 2, 0);
    woof.position = Vector2(-size.x * 2, 0);
    machine.position = Vector2(-size.x * 2, 0);
    microphone.position = Vector2(-size.x * 2, 0);
    cardPanel.position = Vector2(-size.x * 2, 0);
    fadeSlide.position = Vector2(-size.x * 2, 0);
    syllablePanel.position = Vector2(-size.x * 2, 0);
    splash.position = Vector2(-size.x * 2, 0);
    background.position = Vector2(0, 0);
    delayedInitialize();

    gameUtil.delayer
        .wait(
          milliseconds: 2000,
          run: () async {
            animationBackground = AnimationBackground(
              width: size.x,
              height: size.y,
              gameUtil: gameUtil,
            );
            animationBackground.position = Vector2(0, 0);
            add(animationBackground);
            background.setVisibility(false);

            await add(joy);
            await add(woof);
            await add(machine);
            await add(microphone);
            await add(cardPanel);
            await add(fadeSlide);
            await add(syllablePanel);
            await add(background);
          },
        )
        .catchError((_) {});
  }

  void delayedInitialize() async {
    final _player =
        await jsAudioManager.playUISound("Title-appearing-sound.mp3");

    splash.position = Vector2(0, 0);

    if (splash.isPlayed)
      beforeStage(StageStatus.BeforeStage);
    else {
      beforeStage(StageStatus.SplashStage);
      splash.setPlayed();
    }
  }

  /* ----- Stage Functions ---------  */
  void flyBoxStage() {
    timePlaying = 0;
    stageStatus = StageStatus.FlyBoxStage;
    jsAudioManager.playUISound("Camera-shift.mp3");
  }

  void clappingStage() {
    timePlaying = 0;
    stageStatus = StageStatus.MachineWorkingStage;
    machine.hideMachineInput();
    cardPanel.increaseRightCount();

    gameUtil.delayer
        .wait(
          milliseconds: 1000,
          run: () async {
            if (woofAudioList.contains(machine.structure)) {
              woof.startClappingAndSpeaking();
              joy.startJustClapping();
            } else {
              // This means joyAudioList contains machine.structure
              woof.startJustClapping();
              joy.startClappingAndSpeaking();
            }
          },
        )
        .catchError((_) {});
  }

  void wrongAnswerStage() {
    timePlaying = 0;
    stageStatus = StageStatus.WrongAnswerStage;
  }

  void introStage() {
    overlays.add('Intro-Video');
  }

  void outroStage() async {
    stageStatus = StageStatus.OutroStage;
    woof.position = Vector2(39.8 * widthRatio - size.x, 284.9 * heightRatio);
    joy.position = Vector2(187.52 * widthRatio - size.x, 300.82 * heightRatio);
    microphone.position =
        Vector2(179.15 * widthRatio - size.x, 373.93 * heightRatio);
    machine.position.x = 323.69 * widthRatio - size.x;
    outroFireworks.position = Vector2((size.x - size.y * 1.2) / 2, 0);
    jsAudioManager.playBackgroundMusic(
      backgroundMusicUrl: "Bonuscard-appearance-sound.mp3",
    );

    await add(outroFireworks).then((value) => {
          outroFireworks.setSize(size.y * 1.2, size.y),
          outroFireworks.startFireworks(),
        });
  }

  void setJumpStage() {
    woof.position = Vector2(39.8 * widthRatio, 245.9 * heightRatio);
    joy.position = Vector2(size.x - size.x / 3.33, 250.82 * heightRatio);

    List<double> horizontalPositionList = [];
    List<String> structureList = machine.structure.split("-");

    if (machine.syllable == 1) {
      horizontalPositionList.add(size.x / 2 - 60);
    } else if (machine.syllable == 2) {
      horizontalPositionList.add(size.x / 2 - 80 - 60);
      horizontalPositionList.add(size.x / 2 + 80 - 60);
    } else if (machine.syllable == 3) {
      horizontalPositionList.add(size.x / 2 - 100 - 60);
      horizontalPositionList.add(size.x / 2 - 60);
      horizontalPositionList.add(size.x / 2 + 100 - 60);
    }

    for (int i = 0; i < structureList.length; ++i) {
      machine.flyOutCubeList.add(
        FlyOutCube(
          text: structureList[i],
          gameUtil: gameUtil,
        ),
      );
      machine.flyOutCubeList[i].initCube().then(
            (value) => {
              machine.flyOutCubeList[i].setParameters(1, 120, 120, i + 1),
              machine.flyOutCubeList[i].position = Vector2(
                horizontalPositionList[i],
                joy.position.y + joy.height / 1.1 - 120,
              ),
              add(machine.flyOutCubeList[i]),
            },
          );
    }
  }

  void setStage() {
    background.setVisibility(false);
    stageStatus = StageStatus.SetStage;
    woof.position = Vector2(15 * widthRatio, 245.9 * heightRatio);
    joy.position = Vector2(147.52 * widthRatio, 250.82 * heightRatio);
    microphone.position = Vector2(154.15 * widthRatio, 390.93 * heightRatio);
    machine.position = Vector2(255 * widthRatio,
        joy.position.y + joy.height - 458.72 * widthRatio / 1.59);
    machine.resetPosition();

    woof.setSize(186.22 * widthRatio, 186.19 * widthRatio);
    joy.setSize(185.08 * widthRatio, 185.16 * widthRatio);
    microphone.setSize(29.64 * widthRatio, 79.81 * widthRatio);
    machine.setSize(
        458.53 * widthRatio * 0.95, 458.72 * widthRatio * 0.95 / 1.59);

    addHandComponent();
    wordStep = (wordStep + 1) % 9;
    if (wordStep % 3 == 0) {
      cardPanel.initBackground().then(
        (value) {
          gameUtil.delayer
              .wait(
                milliseconds: 500,
                run: () async {
                  jsAudioManager.playUISound("Syllable-buttons-slide-in.mp3");
                  cardPanel.currentTimerPlaying = 0;
                  cardPanel.cardPanelAnimationType =
                      CardPanelAnimationType.SlideIn;
                },
              )
              .catchError((_) {});

          addTimerComponent(HandAnimationType.HandTutorialAnimation);
        },
      );
    } else {
      gameUtil.delayer
          .wait(
            milliseconds: 500,
            run: () async {
              jsAudioManager.playUISound("Syllable-buttons-slide-in.mp3");
            },
          )
          .catchError((_) {});

      cardPanel.cardPanelAnimationType = CardPanelAnimationType.SlideIn;
      addTimerComponent(HandAnimationType.HandTutorialAnimation);
    }
    animationBackground.position.x = 0;
    outroFinish = false;
  }

  void beforeStage(StageStatus currentStageStatus) {
    woof.position = Vector2(335.71 * widthRatio - size.x, 241.16 * heightRatio);
    joy.position = Vector2(539.73 * widthRatio - size.x, 254.62 * heightRatio);
    microphone.position =
        Vector2(522.47 * widthRatio - size.x, 304.88 * heightRatio);
    machine.position =
        Vector2(579.73 * widthRatio - size.x - 500, 226.89 * heightRatio);
    cardPanel.position = Vector2(size.x, 0);
    fadeSlide.position = Vector2(-size.x, 0);
    machine.clearFlyOutCubes();
    initSyllablePanel();

    timePlaying = 0;
    stageStatus = currentStageStatus;
  }

  void setDraggingIndex(int syllable) {
    ComponentSet c = createComponentSet();

    c.changePriority(fadeSlide, 100);
    c.changePriority(hand, 9);
    for (int i = 0; i < 3; ++i) {
      if (i == syllable - 1) {
        c.changePriority(cardPanel.cardList[i], 8);
      } else {
        c.changePriority(cardPanel.cardList[i], 1);
      }
    }

    this.reorderChildren();
  }

  void playWrongSound() {
    var now = new DateTime.now();
    Random random = new Random(now.millisecondsSinceEpoch);
    List<String> characters = ["JOY", "WOOF"];
    List<int> wordsRange = [5, 6];
    int characterNumber = random.nextInt(3) % 2;

    if (characterNumber == 0) {
      joy.speak();
    } else {
      woof.speak();
    }
    jsAudioManager.sayWrong(characters[characterNumber],
        (random.nextInt(20) % wordsRange[characterNumber] + 1).toString());
  }

  void startSyllablePronunciation() {
    timePlaying = 0;
    stageStatus = StageStatus.SyllablePronunciationStage;
  }

  @override
  void update(double t) {
    super.update(t);

    if (stageStatus == StageStatus.None) {
      timePlaying += t;
      if (timePlaying > 2 && timePlaying < 3) {
      } else if (timePlaying > 6) {
        timePlaying = 0;
        stageStatus = StageStatus.BeforeStage;
      }
    } else if (stageStatus == StageStatus.SplashStage) {
    } else if (stageStatus == StageStatus.BeforeStage) {
      timePlaying += t;
      stageStatus = StageStatus.IntroStage;
      introStage();

      ///////////////  Temparary debugging outrostage /////////////////
      //background.setVisibility(true);
      //outroStage();
      /////////////////////////////////////////////////////////////////

      timePlaying = 0;
    } else if (stageStatus == StageStatus.IntroStage) {
      timePlaying += t;

      if (timePlaying >= 0 && timePlaying < 11) {
      } else {
        timePlaying = 0;
        stageStatus = StageStatus.None;
        fadeSlide.setAfterFadeOutCall(() {
          overlays.remove('Intro-Video');
          setStage();
          //outroStage();
          timePlaying = 0;
        });
        fadeSlide.fadeOut();
      }
    } else if (stageStatus == StageStatus.SetStage) {
      if (jsAudioManager.checkFinished()) {
        // When Joy says how many syllables are in the word
      }
    } else if (stageStatus == StageStatus.WrongAnswerStage) {
      timePlaying += t;
      if (timePlaying >= 0 && timePlaying < 3) {
        /* Characters say the choice is wrong */
      } else {
        initSyllablePanel();
      }
    } else if (stageStatus == StageStatus.SyllablePronunciationStage) {
      timePlaying += t;

      double eachCubeJumpFinishedTime = machine.syllable * 1.5;

      for (int i = 0; i < machine.syllable; ++i) {
        if (timePlaying >= 1.5 * i && timePlaying < 1.5 * (i + 1)) {
          if (timePlaying >= 1.5 * i && timePlaying < 1.5 * i + 0.3) {
            joy.settingClappingFlag = false;
          } else if (timePlaying >= 1.5 * i + 0.3) {
            if (machine.syllable > i) {
              if (joy.settingClappingFlag == false) {
                joy.settingClappingFlag = true;
                joy.jump();
                woof.clap();

                if (machine.syllable == 1) {
                  if (i == 0) {
                    if (woofAudioList.contains(machine.structure)) {
                      jsAudioManager.sayWord("WOOF", machine.structure);
                      woof.speak();
                    }
                    if (joyAudioList.contains(machine.structure)) {
                      jsAudioManager.sayWord("JOY", machine.structure);
                      //joy.speak();
                    }
                  }
                } else {
                  if (joyAudioList.contains(machine.structure)) {
                    jsAudioManager.saySeparated(
                        "JOY", machine.structure + "_0" + (i + 1).toString());
                  } else {
                    jsAudioManager.saySeparated(
                        "WOOF", machine.structure + "_0" + (i + 1).toString());
                  }
                }
              }
            }
          }
          if (machine.syllable > i) {
            if (timePlaying >= 1.5 * i + 0.3 && timePlaying < 1.5 * i + 0.8) {
              machine.flyOutCubeList[i].width -= (60 * t);
              machine.flyOutCubeList[i].height -= (6 * t);
              machine.flyOutCubeList[i].position.x += (20 * t);
              machine.flyOutCubeList[i].position.y -= (60 * t);
              joy.position.y -= (40 * t);
              //jsAudioManager.playUISound("Cube-jump.mp3");
            } else if (timePlaying >= 1.5 * i + 0.8 &&
                timePlaying < 1.5 * i + 1.3) {
              machine.flyOutCubeList[i].width += (60 * t);
              machine.flyOutCubeList[i].height += (6 * t);
              machine.flyOutCubeList[i].position.x -= (20 * t);
              machine.flyOutCubeList[i].position.y += (60 * t);
              joy.position.y += (40 * t);
            } else if (timePlaying >= 1.5 * i + 1.3) {
              machine.flyOutCubeList[i].position.y =
                  joy.position.y + joy.height / 1.1 - 120;
            }
          }
        }
      }

      if (timePlaying >= 0 && timePlaying < eachCubeJumpFinishedTime) {
      } else if (timePlaying >= eachCubeJumpFinishedTime &&
          timePlaying < eachCubeJumpFinishedTime + 0.5) {
        if (syllablePronunciationFlag == false) {
          if (syllablePronunciationFlag == false) {
            if (wordStep % 3 != 0) {
              jsAudioManager.playUISound("Cube-slide.mp3");
            }
          }

          syllablePronunciationFlag = true;
          if (joyAudioList.contains(machine.structure)) {
            jsAudioManager.sayWord("JOY", machine.structure);
            joy.speak();
          }
          if (woofAudioList.contains(machine.structure)) {
            jsAudioManager.sayWord("WOOF", machine.structure);
            woof.speak();
          }
        }
        if (machine.syllable == 2) {
          machine.flyOutCubeList[0].position.x = animationHelper.calculateLimit(
              machine.flyOutCubeList[0].position.x + 80 * t,
              machine.flyOutCubeList[1].position.x,
              true);
          machine.flyOutCubeList[1].position.x = animationHelper.calculateLimit(
              machine.flyOutCubeList[1].position.x - 80 * t,
              machine.flyOutCubeList[0].position.x,
              false);
        } else if (machine.syllable == 3) {
          machine.flyOutCubeList[0].position.x = animationHelper.calculateLimit(
              machine.flyOutCubeList[0].position.x + 45 * t,
              machine.flyOutCubeList[1].position.x,
              true);
          machine.flyOutCubeList[2].position.x = animationHelper.calculateLimit(
              machine.flyOutCubeList[2].position.x - 45 * t,
              machine.flyOutCubeList[1].position.x,
              false);
        }
      } else if (timePlaying >= eachCubeJumpFinishedTime + 0.5 &&
          timePlaying < eachCubeJumpFinishedTime + 1) {
        // Delay for word pronunciation complete
      } else if (timePlaying >= eachCubeJumpFinishedTime + 1 &&
          timePlaying < eachCubeJumpFinishedTime + 1.5) {
        joy.laugh();
        woof.laugh();
        jsAudioManager.playLaughAudio();
      } else if (timePlaying >= eachCubeJumpFinishedTime + 1.5 &&
          timePlaying < eachCubeJumpFinishedTime + 3) {
      } else {
        syllablePronunciationFlag = false;

        timePlaying = 0;
        stageStatus = StageStatus.None;
        fadeSlide.setAfterFadeOutCall(() {
          joy.reset();
          woof.reset();
          machine.resetMachine();

          if (wordStep % 3 == 2) {
            giftCardShow();
          } else {
            setStage();
            timePlaying = 0;
          }
        });
        fadeSlide.fadeOut();
      }
    } else if (stageStatus == StageStatus.FlyBoxStage) {
      timePlaying += t;
      if (timePlaying >= 0 && timePlaying < 1) {
        /* Characters come out to the stage */
        double leftMovingDistance = size.x / 2.3;

        if (Platform.isIOS) {
          leftMovingDistance = size.x / 2.3 + 50;
        }

        machine.position.add(Vector2(-leftMovingDistance * t, 0));
        joy.position.add(Vector2(-leftMovingDistance * t, 0));
        woof.position.add(Vector2(-leftMovingDistance * t, 0));
        microphone.position.add(Vector2(-leftMovingDistance * t, 0));
        animationBackground.position.x -= leftMovingDistance * t;
      } else if (timePlaying >= 1 && timePlaying < 3) {
        machine.startFiring();
        timePlaying = 0;
        stageStatus = StageStatus.SetStage;
      } else {
        //stageStatus = StageStatus.JumpingStage;
        //timePlaying = 0;
      }
    } else if (stageStatus == StageStatus.GiftCardHideStage) {
      timePlaying += t;
      if (timePlaying >= 0 && timePlaying < 1) {
        for (int i = 0; i < 3; ++i) {
          giftCardList[i].position -= Vector2(0, size.y * t);
          giftSyllableButtonList[i].position += Vector2(0, size.y * t);
        }
      } else {
        double horizontalSpace136 =
            (size.x - 136 * widthRatio * 3 - 30 * 2) / 2;
        for (int i = 0; i < 3; ++i) {
          giftCardList[i].position = Vector2(
            horizontalSpace136 + 136 * widthRatio * i + 30 * i,
            size.y / 2 - 126 * widthRatio - size.y,
          );
          giftSyllableButtonList[i].position = Vector2(
            giftCardList[i].position.x + (136 - 100) * widthRatio / 2,
            size.y / 2 + 20 + size.y,
          );
        }

        if (wordStep == 8) {
          fadeSlide.setAfterFadeOutCall(() {
            background.setVisibility(true);
            outroStage();
          });
        } else {
          fadeSlide.setAfterFadeOutCall(() {
            joy.reset();
            woof.reset();
            machine.resetMachine();
            timePlaying = 0;
            setStage();
          });
        }

        timePlaying = 0;
        stageStatus = StageStatus.None;

        jsAudioManager.playUISound("Card-slide-out.mp3");
        fadeSlide.fadeOut();
      }
    } else if (stageStatus == StageStatus.GiftCardStage) {
      timePlaying += t;
      if (timePlaying >= 0 && timePlaying < 1) {
        for (int i = 0; i < 3; ++i) {
          giftCardList[i].position += Vector2(0, size.y * t);
          giftSyllableButtonList[i].position -= Vector2(0, size.y * t);
        }
      } else if (timePlaying >= 1 && timePlaying < 2) {
        double horizontalSpace136 =
            (size.x - 136 * widthRatio * 3 - 30 * 2) / 2;
        for (int i = 0; i < 3; ++i) {
          giftCardList[i].position = Vector2(
            horizontalSpace136 + 136 * widthRatio * i + 30 * i,
            size.y / 2 - 126 * widthRatio,
          );
          giftSyllableButtonList[i].position = Vector2(
            giftCardList[i].position.x + (136 - 100) * widthRatio / 2,
            size.y / 2 + 20,
          );
        }
        woof.position = Vector2(5 * widthRatio, 245.9 * heightRatio);
        joy.position =
            Vector2(size.x - 180.8 * widthRatio, 250.82 * heightRatio);
      } else if (timePlaying >= 2 && timePlaying < 6.5) {
        for (int i = 0; i < 3; ++i) {
          double lowerLimit = i * (i + 1) / 2 * 0.7;
          double upperLimit = lowerLimit + (i + 1) * 0.7;
          if (timePlaying >= 2 + lowerLimit &&
              timePlaying < 2 + lowerLimit + 0.45) {
            if (giftSyllableButtonList[i].scaleFactor == Vector2(1.0, 1.0)) {
              giftSyllableButtonList[i].currentTimerPlaying = 0;
              giftSyllableButtonList[i].animationType =
                  SyButtonAnimationType.NotifyWithZoom;

              giftCardList[i].notifyWithZoom();

              if (woofAudioList.contains(giftCardList[i].structure)) {
                woof.simpleClapAndSay(
                  true,
                  isAudible: false,
                  syllableCount: i + 1,
                );
                joy.simpleClapAndSay(
                  false,
                  isAudible: false,
                  syllableCount: i + 1,
                );
              }
              if (joyAudioList.contains(giftCardList[i].structure)) {
                woof.simpleClapAndSay(
                  false,
                  isAudible: false,
                  syllableCount: i + 1,
                );
                joy.simpleClapAndSay(
                  true,
                  isAudible: false,
                  syllableCount: i + 1,
                );
              }
            }
          }
          if (timePlaying >= 2 + lowerLimit && timePlaying < 2 + upperLimit) {
            for (int j = 0; j < giftCardList[i].syllable; ++j) {
              if (timePlaying >= 2 + lowerLimit + j * 0.7 &&
                  timePlaying < 2 + lowerLimit + j * 0.7 + 0.35) {
                if (giftCardList[i].syllable == 1) {
                  if (woofAudioList.contains(giftCardList[i].structure)) {
                    jsAudioManager.sayWord("WOOF", giftCardList[i].structure);
                  }
                  if (joyAudioList.contains(giftCardList[i].structure)) {
                    jsAudioManager.sayWord("JOY", giftCardList[i].structure);
                  }
                } else {
                  if (woofAudioList.contains(giftCardList[i].structure)) {
                    jsAudioManager.saySeparated("WOOF",
                        giftCardList[i].structure + "_0" + (j + 1).toString());
                  }
                  if (joyAudioList.contains(giftCardList[i].structure)) {
                    jsAudioManager.saySeparated("JOY",
                        giftCardList[i].structure + "_0" + (j + 1).toString());
                  }
                }
              }
            }
          }
        }
      } else if (timePlaying >= 6.5 && timePlaying < 7.5) {
        jsAudioManager.speak("Woof", "Well-done-you-match-all.mp3");
        woof.askQuestion();
      } else if (timePlaying >= 7.5 && timePlaying < 9.5) {
      } else {
        jsAudioManager.checkFinished();
        giftCardHide();
      }
    } else if (stageStatus == StageStatus.OutroStage) {
      timePlaying += t;
      if (timePlaying >= 0 && timePlaying < 2.5) {
      } else {
        hoorayCount = 0;
        if (outroFinish == false) {
          overlays.add('Outro-Video');
          outroFinish = true;
        }
      }
    }
  }

  //////// Add or Remove Functions /////////
  void giftCardHide() async {
    stageStatus = StageStatus.GiftCardHideStage;
    timePlaying = 0;
  }

  void giftCardShow() async {
    hoorayCount = hoorayCount + 1;

    woof.position = Vector2(5 * widthRatio, 245.9 * heightRatio);
    joy.position = Vector2(size.x - 180.8 * widthRatio, 250.82 * heightRatio);
    animationBackground.position.x = 0;

    giftCardList.clear();
    giftSyllableButtonList.clear();

    double horizontalSpace136 = (size.x - 136 * widthRatio * 3 - 30 * 2) / 2;
    for (int i = 0; i < 3; ++i) {
      giftCardList.add(
        JSCard.Card(
          jsGame: this,
          text: cardPanel.cardList[i].text,
          syllable: cardPanel.cardList[i].syllable,
          structure: cardPanel.cardList[i].structure,
          width: 136,
          height: 136,
          isTappable: false,
        ),
      );
      giftCardList[i].position = Vector2(
        horizontalSpace136 + 136 * widthRatio * i + 30 * i,
        size.y / 2 - 136 * widthRatio - size.y,
      );
      add(giftCardList[i]);
    }
    for (int i = 0; i < 3; ++i) {
      giftSyllableButtonList.add(
        SyllableButton(
          jsGame: this,
          syllable: cardPanel.cardList[i].syllable,
          isTappable: false,
        ),
      );
      giftSyllableButtonList[i].position = Vector2(
        giftCardList[i].position.x + (136 - 100) * widthRatio / 2,
        size.y / 2 + 20 + size.y,
      );

      if (i == 2) {
        await giftSyllableButtonList[i].initButton().then(
              (value) => {
                add(giftSyllableButtonList[i]),
                timePlaying = 0,
                stageStatus = StageStatus.GiftCardStage,
                jsAudioManager.playUISound("Card-slide-in.mp3")
              },
            );
      } else {
        await giftSyllableButtonList[i].initButton().then(
              (value) => {
                add(giftSyllableButtonList[i]),
              },
            );
      }
    }

    //////////////// ------- Just For Debugging Process --------- ////////////

    machine.position = Vector2(-size.x * 2, 0);
    microphone.position = Vector2(-size.x * 2, 0);

    //////////////// ------- Just For Debugging Process --------- ////////////
  }

  void removeTimerComponent() {
    remove(timerComponent);
  }

  void addTimerComponent(HandAnimationType handAnimType) {
    if (handAnimType == HandAnimationType.HandIndicationAnimation) {
      int syllable = 3 - machine.syllable;
      hand.position = Vector2(
          size.x - 80, syllablePanel.syllableButtonList[syllable].y + 50);
    }
    if (handAnimType == HandAnimationType.HandTutorialAnimation) {
      for (int i = 0; i < 3; ++i) {
        if (cardPanel.cardList[i].isInBoard == false) {
          hand.position = Vector2(size.x - 80, cardPanel.cardList[i].y + 50);
          hand.savePosition();
          break;
        }
      }
    }

    timerComponent = TimerComponent(
        period: 10,
        repeat: true,
        onTick: () => {
              hand.opacity = 0,
              hand.currentTimerPlaying = 0,
              hand.handAnimationType = handAnimType,
            })
      ..timer.start();

    add(timerComponent);
  }

  void removeCardPanel() {
    cardPanel.position.add(Vector2(size.x, 0));
    for (int i = 0; i < 3; ++i) {
      cardPanel.cardList[i].position.x = size.x + 200;
    }
  }

  void removeHandComponent() {
    remove(hand);
  }

  void addHandComponent() {
    hand = Hand(jsGame: this);
    hand.initHand().then((value) => {add(hand)});
  }

  void initSyllablePanel() {
    syllablePanel.position = Vector2(size.x + 50, 0);
  }
}
