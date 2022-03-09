import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Microphone extends SpriteAnimationComponent with HasGameRef {
  Microphone({
    required this.width,
    required this.height,
    required this.gameUtil,
  }) : super(size: Vector2(width, height));

  final GameUtil gameUtil;
  late final SpriteAnimation waitingAnimation;
  final double width;
  final double height;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    animation = waitingAnimation;
  }

  void setSize(double sizeWidth, double sizeHeight) {
    size = Vector2(sizeWidth, sizeHeight);
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  Future<void> loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameUtil.assetManager.loadUiImage('images/' + 'microphone.png'),
      srcSize: Vector2(167, 479),
    );
    waitingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.5, to: 1);
  }
}
