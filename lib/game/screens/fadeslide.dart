import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'jsgame.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class FadeSlide extends PositionComponent with HasGameRef {
  final JSGame jsGame;

  FadeSlide({required this.jsGame, required this.width, required this.height})
      : super(size: Vector2(width, height));

  double currentTimerPlaying = 0.0;
  FadeSlideStatus fadeSlideStatus = FadeSlideStatus.None;
  Function afterFadeOutCall = () {};

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  void setAfterFadeOutCall(Function function) {
    afterFadeOutCall = function;
  }

  void fadeIn() {
    currentTimerPlaying = 0;
    fadeSlideStatus = FadeSlideStatus.FadeIn;
    print("[DEBUG] - fading into normal screen");
  }

  void fadeOut() {
    currentTimerPlaying = 0;
    fadeSlideStatus = FadeSlideStatus.FadeOut;
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (fadeSlideStatus == FadeSlideStatus.None) {}
    else if (fadeSlideStatus == FadeSlideStatus.FadeOut) {
      currentTimerPlaying += delta;
      if (currentTimerPlaying >= 0 && currentTimerPlaying < 1) {
        opacity += 1 * delta;
        opacity = opacity > 1 ? 1 : opacity;
      } else {
        opacity = 1;
        afterFadeOutCall();
        fadeIn();
      }
    }
    else if (fadeSlideStatus == FadeSlideStatus.FadeIn) {
      currentTimerPlaying += delta;
      if (currentTimerPlaying >= 0 && currentTimerPlaying < 1) {
        opacity -= 1 * delta;
        opacity = opacity < 0 ? 0 : opacity;
      } else {
        opacity = 0;
        currentTimerPlaying = 0;
        fadeSlideStatus = FadeSlideStatus.None;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    Paint opacityPaint = Paint()
      ..color = Colors.black.withOpacity(opacity);
    canvas.drawRect(rect, opacityPaint);
  }

  final double width;
  final double height;
  double opacity = 0;
}