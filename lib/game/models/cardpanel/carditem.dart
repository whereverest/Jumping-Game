import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class CardItem extends PositionComponent {
  CardItem({
    required this.widthRatio,
    required this.heightRatio,
    required this.text,
    required this.syllable,
    required this.width,
    required this.height,
    required this.gameUtil,
  }) : super();

  final GameUtil gameUtil;

  Future<void> onLoad() async {
    super.onLoad();

    var cardImage = await gameUtil.assetManager.loadUiImage(
      'images/' + syllable.toString() + '_syllable/' + text + '.png',
    );
    var backImage = await gameUtil.assetManager.loadUiImage(
      'images/' + 'Card_Base.png',
    );

    imageBlock = Sprite(cardImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(476, 431));
    backBlock = Sprite(backImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(474, 443));
  }

  void notifyWithZoom() {
    if (scaleFactor == Vector2(1.0, 1.0)) {
      cardItemAnimationType = CardItemAnimationType.NotifyWithZoom;
      currentTimerPlaying = 0;
    }
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (cardItemAnimationType == CardItemAnimationType.None) {
    } else if (cardItemAnimationType == CardItemAnimationType.NotifyWithZoom) {
      currentTimerPlaying += delta;

      if (currentTimerPlaying >= 0 && currentTimerPlaying < 0.35) {
        scaleFactor.x += 0.5 * delta;
        scaleFactor.y += 0.5 * delta;
      } else if (currentTimerPlaying >= 0.35 && currentTimerPlaying < 0.7) {
        scaleFactor.x -= 0.5 * delta;
        scaleFactor.y -= 0.5 * delta;
      }
      if (syllable > 1) {
        if (currentTimerPlaying >= 0.7 && currentTimerPlaying < 1.05) {
          scaleFactor.x += 0.5 * delta;
          scaleFactor.y += 0.5 * delta;
        } else if (currentTimerPlaying >= 1.05 && currentTimerPlaying < 1.4) {
          scaleFactor.x -= 0.5 * delta;
          scaleFactor.y -= 0.5 * delta;
        }
      }
      if (syllable > 2) {
        if (currentTimerPlaying >= 1.4 && currentTimerPlaying < 1.75) {
          scaleFactor.x += 0.5 * delta;
          scaleFactor.y += 0.5 * delta;
        } else if (currentTimerPlaying >= 1.75 && currentTimerPlaying < 2.1) {
          scaleFactor.x -= 0.5 * delta;
          scaleFactor.y -= 0.5 * delta;
        }
      }
      if (currentTimerPlaying >= 0.7 * syllable) {
        scaleFactor = Vector2(1.0, 1.0);
        currentTimerPlaying = 0;
        cardItemAnimationType = CardItemAnimationType.None;
      }
    } else {}
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    backBlock.renderRect(
        canvas,
        Rect.fromLTWH(
            -(90 * widthRatio * width / 100 / 2 * (scaleFactor.x - 1)),
            -(90 * widthRatio * width / 100 / 2 * (scaleFactor.y - 1)),
            90 * widthRatio * width / 100 * scaleFactor.x,
            90 * widthRatio * width / 100 * scaleFactor.y));
    imageBlock.renderRect(
        canvas,
        Rect.fromLTWH(
            10 * widthRatio * width / 100 * scaleFactor.x -
                70 * widthRatio * width / 100 * (scaleFactor.x - 1) / 2,
            15.5 * widthRatio * width / 100 * scaleFactor.y -
                59 * widthRatio * width / 100 * (scaleFactor.y - 1) / 2,
            70 * widthRatio * width / 100 * scaleFactor.x,
            59 * widthRatio * width / 100 * scaleFactor.y));
  }

  late TextPaint textPaint;
  late Sprite imageBlock;
  late Sprite backBlock;
  final String text;
  final int syllable;
  final double widthRatio;
  final double heightRatio;
  final double width;
  final double height;
  CardItemAnimationType cardItemAnimationType = CardItemAnimationType.None;
  double currentTimerPlaying = 0;
  Vector2 scaleFactor = Vector2(1.0, 1.0);
}
