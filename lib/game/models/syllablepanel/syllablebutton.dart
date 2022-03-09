import 'dart:io' show Platform;
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:jumping_syllables/game/animation_helper.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class SyllableButton extends PositionComponent
    with HasGameRef<JSGame>, Tappable {
  final JSGame jsGame;

  SyllableButton({
    required this.jsGame,
    required this.syllable,
    required this.isTappable,
  }) : super(size: Vector2(100 * jsGame.widthRatio, 100 * jsGame.heightRatio));

  SyButtonAnimationType animationType = SyButtonAnimationType.None;
  double currentTimerPlaying = 0.0;
  int shakeStep = 6;
  Vector2 originalPosition = Vector2(0, 0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  Future<void> initButton() async {
    var buttonImage = await jsGame.gameUtil.assetManager
        .loadUiImage('images/' + 'Syllable-' + syllable.toString() + '.png');
    buttonBlock = Sprite(buttonImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(427, 426));
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (isTappable) {
      jsGame.jsAudioManager.playUISound("Syllable-button-pull-back.mp3");
      if (jsGame.machine.syllable == syllable) {
        jsGame.syllablePanel.moveRightLinear(syllable);
        jsGame.jsAudioManager.stopSpeaking();
        jsGame.jsAudioManager.checkFinished();
        jsGame.clappingStage();
        jsGame.jsAudioManager.playUISound("Right-match-sound.mp3");
      } else {
        if (animationType == SyButtonAnimationType.None) {
          currentTimerPlaying = 0;
          originalPosition = position.clone();
          animationType = SyButtonAnimationType.ShakeLRContract;
          jsGame.wrongAnswerStage();
          jsGame.jsAudioManager.playUISound("Wrong-match-sound.mp3");
          jsGame.playWrongSound();
        }
      }

      jsGame.hand.handAnimationType = HandAnimationType.None;
      jsGame.hand.opacity = 0;
      jsGame.removeTimerComponent();
    }
    return super.onTapUp(info);
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (animationType == SyButtonAnimationType.MoveLeftLinear) {
      currentTimerPlaying += delta;
      if (currentTimerPlaying < 1) {
        position.add(
            Vector2(-160 * delta - (Platform.isIOS ? 1 : 0) * 40 * delta, 0));
      } else {
        animationType = SyButtonAnimationType.None;
        position = Vector2(-160 - (Platform.isIOS ? 1 : 0) * 40, position.y);
        currentTimerPlaying = 0;
      }
    } else if (animationType == SyButtonAnimationType.ShakeLRContract) {
      currentTimerPlaying += delta;

      if (currentTimerPlaying >= 0 && currentTimerPlaying < 0.1) {
        position.add(Vector2(-300 * delta, 0));
      } else if (currentTimerPlaying >= 0.1 && currentTimerPlaying < 0.2) {
        position.add(Vector2(300 * delta, 0));
      } else if (currentTimerPlaying >= 0.2 && currentTimerPlaying < 0.3) {
        position.add(Vector2(-150 * delta, 0));
      } else if (currentTimerPlaying >= 0.3 && currentTimerPlaying < 0.4) {
        position.add(Vector2(150 * delta, 0));
      } else if (currentTimerPlaying >= 0.4 && currentTimerPlaying < 0.5) {
        position.add(Vector2(-75 * delta, 0));
      } else if (currentTimerPlaying >= 0.5 && currentTimerPlaying < 0.6) {
        position.add(Vector2(75 * delta, 0));
      } else {
        position = originalPosition.clone();
        animationType = SyButtonAnimationType.None;
        currentTimerPlaying = 0;
      }
    } else if (animationType == SyButtonAnimationType.MoveRightLinear) {
      currentTimerPlaying += delta;
      if (currentTimerPlaying < 1) {
        position.add(Vector2(200 * delta, 0));
      } else {
        jsGame.initSyllablePanel();
        position = Vector2(0, position.y);
        animationType = SyButtonAnimationType.None;
        currentTimerPlaying = 0;
      }
    } else if (animationType == SyButtonAnimationType.NotifyWithZoom) {
      currentTimerPlaying += delta;

      for (int i = 0; i < syllable; ++i) {
        if (currentTimerPlaying >= 0.7 * i &&
            currentTimerPlaying < 0.7 * i + 0.35) {
          scaleFactor.x = animationHelper.calculateLimit(
              scaleFactor.x + 0.5 * delta, 1.175, true);
          scaleFactor.y = animationHelper.calculateLimit(
              scaleFactor.y + 0.5 * delta, 1.175, true);
        } else if (currentTimerPlaying >= 0.7 * i + 0.35 &&
            currentTimerPlaying < 0.7 * i + 0.7) {
          scaleFactor.x = animationHelper.calculateLimit(
              scaleFactor.x - 0.5 * delta, 1, false);
          scaleFactor.y = animationHelper.calculateLimit(
              scaleFactor.y - 0.5 * delta, 1, false);
        }
      }

      if (currentTimerPlaying >= 0 &&
          currentTimerPlaying < 0.7 * syllable - 0.35) {
      } else if (currentTimerPlaying >= 0.7 * syllable + 0.35 &&
          currentTimerPlaying < 0.7 * syllable + 0.7) {
        scaleFactor = Vector2(1, 1); // Delay here for MachineInput hides
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Rect rect = Rect.fromLTWH(
        -(scaleFactor.x - 1) / 2 * 100 * jsGame.widthRatio,
        -(scaleFactor.y - 1) / 2 * 100 * jsGame.widthRatio,
        scaleFactor.x * 100 * jsGame.widthRatio,
        scaleFactor.y * 100 * jsGame.widthRatio);
    buttonBlock.renderRect(canvas, rect);
  }

  final int syllable;
  final bool isTappable;
  Vector2 scaleFactor = Vector2(1.0, 1.0);
  late Sprite buttonBlock;
}
