import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:jumping_syllables/game/characters/machine.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class FlyOutCube extends PositionComponent {
  FlyOutCube({
    required this.text,
    required this.gameUtil,
  }) : super();

  final GameUtil gameUtil;

  Future<void> initCube() async {
    var backImage =
        await gameUtil.assetManager.loadUiImage('images/' + 'Box.png');
    backBlock = Sprite(backImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(1024, 1024));
  }

  void restorePosition() {
    restoredPosition = position.clone();
  }

  void magnifyCube() {
    timePlaying = 0;
    flyOutCubeAnimType = FlyOutCubeAnimType.Magnify;
  }

  void moveCube(Vector2 delta) {
    position += delta;
  }

  void flyOutCube() {
    if (flyOutCubeAnimType == FlyOutCubeAnimType.None) {
      timePlaying = 0;

      double widthRatio = (parent as Machine).jsGame.widthRatio;
      position.x = widthRatio * 458 * 1.325 / 2 + 80;
      position.y = widthRatio * 458 / 1.2 / 2.5 - 458.72 * widthRatio * 0.25;
      flyOutCubeAnimType = FlyOutCubeAnimType.FlyOut;
    }
  }

  double getx() {
    return (parent as Machine).x + position.x - 80;
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (flyOutCubeAnimType == FlyOutCubeAnimType.FlyOut) {
      timePlaying += delta;

      if (timePlaying >= 0 && timePlaying < 3) {
        position += Vector2(750 * delta, -200 * delta);
        angle += 1.2 * delta;
      }
    } else if (flyOutCubeAnimType == FlyOutCubeAnimType.Shrink) {
      timePlaying += delta;

      if (timePlaying >= 0 && timePlaying < 0.1) {
        width = width - width * delta;
        height = height - height * delta;
        position += Vector2(120 * delta, 90 * delta);
      } else if (timePlaying >= 0.1 && timePlaying < 0.2) {
        width = width + width * 5 * delta;
        height = height + width * 5 * delta;
      } else {
        position = restoredPosition.clone() + Vector2(13, 10);
        width = 80 * 3 / 2;
        height = 60 * 3 / 2;
        timePlaying = 0;
        flyOutCubeAnimType = FlyOutCubeAnimType.None;
      }
    } else if (flyOutCubeAnimType == FlyOutCubeAnimType.Magnify) {
      timePlaying += delta;
    } else {}
  }

  void setParameters(
      double pOpacity, double pWidth, double pHeight, int vFlyScale) {
    opacity = pOpacity;
    width = pWidth;
    height = pHeight;
    flyScale = vFlyScale;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Paint opacityPaint = Paint()..color = Colors.white.withOpacity(opacity);
    backBlock.renderRect(canvas, Rect.fromLTWH(0, 0, width, height),
        overridePaint: opacityPaint);

    if (flyOutCubeAnimType == FlyOutCubeAnimType.FlyOut) {
      textPaint = TextPaint(
        style: TextStyle(
            fontSize: text.length < 5 ? 14.0 : 10.0,
            fontFamily: 'Awesome Font',
            color: Colors.black),
      );
    } else {
      textPaint = TextPaint(
        style: TextStyle(
            fontSize: text.length < 5 ? 18.0 : 14.0,
            fontFamily: 'Awesome Font',
            color: Colors.black),
      );
    }
    textPaint.render(canvas, text, Vector2(width / 2, height / 2),
        anchor: Anchor.center);
  }

  late TextPaint textPaint;
  late Sprite backBlock;
  final String text;
  double opacity = 0;
  double width = 120;
  double height = 120;
  FlyOutCubeAnimType flyOutCubeAnimType = FlyOutCubeAnimType.None;
  double timePlaying = 0;
  Vector2 restoredPosition = Vector2(0, 0);
  int flyScale = 1;
}
