import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';

class Splash extends PositionComponent with HasGameRef<JSGame> {
  Splash({
    required this.width,
    required this.height,
  }) : super(size: Vector2(width, height));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    var backImage = await gameRef.gameUtil.assetManager
        .loadUiImage('images/Splash-BG-min.jpg');
    backBlock = Sprite(backImage,
        srcPosition: Vector2(0, (2400 - 3200 / width * height) / 2),
        srcSize: Vector2(3200, 3200 / width * height));
  }

  void setPlayed() {
    isPlayed = true;
  }

  @override
  void update(double delta) {
    super.update(delta);

    currentTimePlaying += delta;
    if (currentTimePlaying < 2) {
      double temp = opacity - 0.5 * delta;
      opacity = temp < 0 ? 0 : temp;
    } else {
      currentTimePlaying = 1000;
      opacity = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    Paint colorPaint = Paint()..color = Colors.black.withOpacity(opacity);
    canvas.drawRect(rect, colorPaint);
  }

  final double width;
  final double height;
  late Sprite backBlock;
  bool isPlayed = false;
  double opacity = 1.0;
  double currentTimePlaying = 0;
}
