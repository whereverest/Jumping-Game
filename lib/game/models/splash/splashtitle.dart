import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';

class SplashTitle extends SpriteAnimationComponent with HasGameRef<JSGame> {
  SplashTitle({
    required this.width,
    required this.height,
  }) : super(
          size: Vector2(width, height),
        );

  late final SpriteAnimation waitingAnimation;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await initAnimations();
    animation = waitingAnimation;
  }

  Future<void> initAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.gameUtil.assetManager
          .loadUiImage('images/' + 'Game-name.png'),
      srcSize: Vector2(830.0, 424.0),
    );
    waitingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.5, to: 1);
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  final double width;
  final double height;
}
