
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';

class Woof extends SpriteAnimationComponent with HasGameRef, Tappable {
  final JSGame jsGame;

  Woof({
    required this.jsGame,
    required this.width,
    required this.height,
  }) : super(size: Vector2(width, height));

  late final SpriteAnimation waitingAnimation;
  late final SpriteAnimation clappingAnimation;
  late final SpriteAnimation justClappingAnimation;
  late final SpriteAnimation laughingAnimation;
  late final SpriteAnimation speakingAnimation;
  final double width;
  final double height;
  double timePlaying = 0;
  WoofStatus woofStatus = WoofStatus.None;
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

  void laugh() {
    timePlaying = 0;
    animation = laughingAnimation;
    animation!.currentIndex = 0;
    woofStatus = WoofStatus.LaughingStatus;
  }

  void speak() {
    animation = speakingAnimation;
    animation!.currentIndex = 0;
    woofStatus = WoofStatus.SpeakingStatus;
  }

  void askQuestion() {
    animation = speakingAnimation;
    animation!.currentIndex = 0;
    woofStatus = WoofStatus.AskingStatus;
  }

  void startJustClapping() {
    animation = justClappingAnimation;
    animation!.currentIndex = 0;
    settingClappingFlag = true;
    woofStatus = WoofStatus.ClappingStatus;
  }

  void startClappingAndSpeaking() {
    animation = clappingAnimation;
    animation!.currentIndex = 0;
    settingClappingFlag = true;
    woofStatus = WoofStatus.ClappingStatus;
  }

  void simpleClapAndSay(bool isWoofWord, {isAudible: true, syllableCount: 1}) {
    if (isWoofWord) {
      animation = clappingAnimation;
    } else {
      animation = justClappingAnimation;
    }
    simpleClapAndSayAudibleFlag = isAudible;
    print("[DEBUG] - isAudible: " + isAudible.toString());

    if (!simpleClapAndSayAudibleFlag) {
      simpleClappingCount = syllableCount;
      print("[DEBUG] - woof clapping - clapping cnt: " + clappingCount.toString() + ", simple cnt: " + simpleClappingCount.toString());
    }

    jsGame.jsAudioManager.stopSpeaking();
    animation!.currentIndex = 0;
    settingClappingFlag = true;
    woofStatus = WoofStatus.SimpleClapAndSayStatus;
  }

  void reset() {
    woofStatus = WoofStatus.None;
    animation = waitingAnimation;
    timePlaying = 0;
    settingClappingFlag = false;
    simpleClapAndSayAudibleFlag = true;
    simpleClappingCount = 0;
    clappingCount = 0;
  }

  void clap() {
    timePlaying = 0;
    animation = clappingAnimation;
    animation!.currentIndex = 0;
    woofStatus = WoofStatus.SyllablePronunciationStatus;
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (woofStatus == WoofStatus.None) {
      animation = waitingAnimation;
    } else if (woofStatus == WoofStatus.AskingStatus) {
      timePlaying += delta;

      if (timePlaying >= 0 && timePlaying < 4) {
      } else {
        animation = waitingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        woofStatus = WoofStatus.None;
      }
    } else if (woofStatus == WoofStatus.SpeakingStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == animation!.frames.length - 1) {
        animation = waitingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        woofStatus = WoofStatus.None;
      }
    } else if (woofStatus == WoofStatus.SimpleClapAndSayStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == 0) {
        if (simpleClapAndSayAudibleFlag) {
          if (jsGame.machine.syllable == 1) {
            if (clappingCount == 0) {
              if (jsGame.woofAudioList.contains(jsGame.machine.structure)) {
                if (settingClappingFlag == true) {
                  jsGame.jsAudioManager
                      .sayWord("WOOF", jsGame.machine.structure);
                }
              }
            }
          } else {
            if (jsGame.woofAudioList.contains(jsGame.machine.structure)) {
              if (settingClappingFlag == true) {
                ///
                /// TODO It's a very bad solution. The same sounds will be called a few times
                ///
                jsGame.jsAudioManager.saySeparated(
                    "WOOF",
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
          clappingCount ++;
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

      print("[DEBUG] - simple clapping count is: " +
          simpleClappingCount.toString());
      if (clappingCount == simpleClappingCount) {
        animation = waitingAnimation;
        animation!.currentIndex = 0;
        timePlaying = 0;
        clappingCount = 0;
        simpleClappingCount = 0;
        if (!simpleClapAndSayAudibleFlag)
          print("[DEBUG] - this is simple clapping audible bug");
        settingClappingFlag = false;
        simpleClapAndSayAudibleFlag = true;
        woofStatus = WoofStatus.None;
      }
    } else if (woofStatus == WoofStatus.ClappingStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == 0) {
        if (jsGame.machine.syllable == 1) {
          if (clappingCount == 0) {
            if (jsGame.woofAudioList.contains(jsGame.machine.structure)) {
              if (settingClappingFlag == true) {
                jsGame.jsAudioManager.sayWord("WOOF", jsGame.machine.structure);
              }
            }
          }
        } else {
          if (jsGame.woofAudioList.contains(jsGame.machine.structure)) {
            if (settingClappingFlag == true) {
              ///
              /// TODO It's a very bad solution. The same sounds will be called a few times
              ///
              jsGame.jsAudioManager.saySeparated(
                  "WOOF",
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
        timePlaying = 0;
        clappingCount = 0;
        woofStatus = WoofStatus.None;
        animation = waitingAnimation;
      }
    } else if (woofStatus == WoofStatus.SyllablePronunciationStatus) {
      timePlaying += delta;

      if (animation!.currentIndex == animation!.frames.length - 1) {
        animation = waitingAnimation;
        timePlaying = 0;
        woofStatus = WoofStatus.None;
      }
    } else if (woofStatus == WoofStatus.LaughingStatus) {
    } else {
      animation = waitingAnimation;
    }
  }

  Future<void> loadAnimations() async {
    var standingWoofImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + "animations/woof/woof-basic-standing.png");
    final spriteSheet = SpriteSheet(
      image: standingWoofImage,
      srcSize: Vector2(512.0 / (3584 / standingWoofImage.width),
          512.0 / (512 / standingWoofImage.height)),
    );
    waitingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.2, to: 7);

    var speakingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/woof/woof-speaking.png');
    var spriteSheet2 = SpriteSheet(
      image: speakingAnimationImage,
      srcSize: Vector2(512.0 / (3584 / speakingAnimationImage.width),
          512.0 / (512 / speakingAnimationImage.height)),
    );
    speakingAnimation =
        spriteSheet2.createAnimation(row: 0, stepTime: 0.2, to: 7);

    var clappingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + "animations/woof/woof-clapping.png");
    final spriteSheet4 = SpriteSheet(
      image: clappingAnimationImage,
      srcSize: Vector2(512.0 / (4096.0 / clappingAnimationImage.width),
          512.0 / (512 / clappingAnimationImage.height)),
    );
    clappingAnimation =
        spriteSheet4.createAnimation(row: 0, stepTime: 0.1, to: 8);

    var justClappingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + "animations/woof/woof-just-clapping.png");
    final spriteSheet5 = SpriteSheet(
      image: justClappingAnimationImage,
      srcSize: Vector2(512.0 / (3584.0 / justClappingAnimationImage.width),
          512.0 / (512 / justClappingAnimationImage.height)),
    );
    justClappingAnimation =
        spriteSheet5.createAnimation(row: 0, stepTime: 0.1, to: 7);

    var laughingAnimationImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'animations/woof/woof-laughing.png');
    var spriteSheet6 = SpriteSheet(
      image: laughingAnimationImage,
      srcSize: Vector2(1024.0 / (13312 / laughingAnimationImage.width),
          1024.0 / (1024 / laughingAnimationImage.height)),
    );
    laughingAnimation =
        spriteSheet6.createAnimation(row: 0, stepTime: 0.1, to: 13);
  }
}
