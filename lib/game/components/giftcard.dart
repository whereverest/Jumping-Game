import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';

class GiftCard extends SpriteAnimationComponent with HasGameRef<JSGame> {
  GiftCard({
    required this.width,
    required this.height,
  }) : super(size: Vector2(width, height));

  late final SpriteAnimation waitingAnimation;
  bool isShown = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    animation = waitingAnimation;
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  Future<void> loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.gameUtil.assetManager
          .loadUiImage('images/' + 'Gift-Card.png'),
      srcSize: Vector2(215.0, 322.0),
    );
    waitingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.5, to: 1);
  }

  final double width;
  final double height;
}
