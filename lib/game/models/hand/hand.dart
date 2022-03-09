import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class Hand extends PositionComponent with HasGameRef {
  final JSGame jsGame;

  Hand({
    required this.jsGame,
  }) : super(size: Vector2.all(50.0));

  HandAnimationType handAnimationType = HandAnimationType.None;
  double currentTimerPlaying = 0.0;
  double opacity = 1.0;
  late final SpriteAnimation waitingAnimation;
  Vector2 originalPosition = Vector2(0, 0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  void savePosition() {
    originalPosition = position.clone();
  }

  void restorePosition() {
    position = originalPosition.clone();
  }

  Future<void> initHand() async {
    var handImage = await jsGame.gameUtil.assetManager.loadUiImage('images/' + 'Hand.png');
    handBlock = Sprite(handImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(417, 418));
    opacity = 0;
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (handAnimationType == HandAnimationType.HandTutorialAnimation) {
      currentTimerPlaying += delta;
      if (currentTimerPlaying >= 0 && currentTimerPlaying < 0.5) {
        double temp = opacity + delta * 2;
        opacity = temp > 1 ? 1 : temp;
      } else if (currentTimerPlaying >= 0.5 && currentTimerPlaying < 2.5) {
        Vector2 offset = jsGame.machine.position +
            jsGame.machine.stickPosition -
            Vector2(0, 70 * jsGame.widthRatio) -
            originalPosition;
        position.add(Vector2(delta * (offset.x / 2), delta * (offset.y / 2)));
      } else if (currentTimerPlaying >= 2.5 && currentTimerPlaying < 3.5) {
      } else if (currentTimerPlaying >= 3.5 && currentTimerPlaying < 5) {
        double temp = opacity - delta * 0.67;
        opacity = temp < 0 ? 0 : temp;
      } else {
        currentTimerPlaying = 0;
        handAnimationType = HandAnimationType.None;
        restorePosition();
        opacity = 0;
      }
    } else if (handAnimationType == HandAnimationType.HandIndicationAnimation) {
      currentTimerPlaying += delta;
      if (currentTimerPlaying > 0 && currentTimerPlaying < 2.5) {
        double temp = opacity + delta * 0.4;
        opacity = temp > 1 ? 1 : temp;
      } else if (currentTimerPlaying >= 2.5 && currentTimerPlaying < 5) {
        double temp = opacity - delta * 0.4;
        opacity = temp < 0 ? 0 : temp;
      } else {
        currentTimerPlaying = 0;
        opacity = 0;
        handAnimationType = HandAnimationType.None;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Rect rect = Rect.fromLTWH(0, 0, 50, 50);
    Paint opacityPaint = Paint()..color = Colors.white.withOpacity(opacity);
    handBlock.renderRect(canvas, rect, overridePaint: opacityPaint);
  }

  late Sprite handBlock;
}
