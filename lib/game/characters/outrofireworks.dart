import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';

class OutroFireWorks extends SpriteAnimationComponent with HasGameRef {
  OutroFireWorks({
    required this.width,
    required this.height,
    required this.gameUtil,
  }) : super(size: Vector2(width, height));

  final GameUtil gameUtil;
  late final SpriteAnimation waitingAnimation;
  late final SpriteAnimation frontAnimation;
  late final SpriteAnimation backAnimation;
  final double width;
  final double height;
  OutroStatus outroStatus = OutroStatus.None;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    animation = waitingAnimation;
  }

  void setSize(double sizeWidth, double sizeHeight) {
    size = Vector2(sizeWidth, sizeHeight);
  }

  void startFireworks() {
    outroStatus = OutroStatus.FrontPlayingStatus;
    animation = frontAnimation;
  }

  void stopFireworks() {
    outroStatus = OutroStatus.None;
    animation = waitingAnimation;
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (outroStatus == OutroStatus.None) {
      width = width;
      height = height;
      position = Vector2(
          ((parent as JSGame).size.x - (parent as JSGame).size.y * 1.2) / 2, 0);
    } else if (outroStatus == OutroStatus.FrontPlayingStatus) {
      if (animation!.isLastFrame) {
        outroStatus = OutroStatus.BackPlayingStatus;
        animation = backAnimation;
        width = width * 2;
        height = height * 1.5;
        position = Vector2(
            ((parent as JSGame).size.x - (parent as JSGame).size.y * 2) / 2, 0);
      }
    } else {}
  }

  Future<void> loadAnimations() async {
    var frontOutroImage = await gameUtil.assetManager
        .loadUiImage('images/' + 'animations/outro/outro-front.png');
    final spriteSheet = SpriteSheet(
      image: frontOutroImage,
      srcSize: Vector2(1170.0 / (24570 / frontOutroImage.width),
          1024.0 / (1024 / frontOutroImage.height)),
    );
    waitingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.5, to: 1);
    frontAnimation = spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 23);

    var backOutroImage = await gameUtil.assetManager
        .loadUiImage('images/' + 'animations/outro/outro-back.png');
    final spriteSheet2 = SpriteSheet(
      image: backOutroImage,
      srcSize: Vector2(1600.0 / (32000 / backOutroImage.width),
          1200.0 / (1200 / backOutroImage.height)),
    );
    backAnimation =
        spriteSheet2.createAnimation(row: 0, stepTime: 0.05, to: 20);
  }
}
