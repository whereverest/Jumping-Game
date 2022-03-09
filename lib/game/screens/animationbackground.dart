
import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class AnimationBackground extends PositionComponent with HasGameRef {
  AnimationBackground({
    required this.width,
    required this.height,
    required this.gameUtil,
  }) : super(
          size: Vector2(width, height),
        );

  final GameUtil gameUtil;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    var backImage =
        await gameUtil.assetManager.loadUiImage('images/' + 'background/Game-BG.png');
    backBlock = Sprite(backImage,
        srcPosition: Vector2(0, (2400 - 3200 / width * height) / 2),
        srcSize: Vector2(6400, 3200 / width * height));
  }

  void setVisibility(bool doShow) {
    if (doShow) {
      opacity = 1.0;
    } else {
      opacity = 0.0;
    }
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Rect rect = Rect.fromLTWH(0, 0, width * 2, height);
    Paint colorPaint = Paint()..color = Colors.black.withOpacity(opacity);
    backBlock.renderRect(canvas, rect, overridePaint: colorPaint);
  }

  final double width;
  final double height;
  late Sprite backBlock;
  double opacity = 1.0;
}
