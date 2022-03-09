import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class MachineBody extends PositionComponent {
  MachineBody({
    required this.gameUtil,
  }) : super();

  final GameUtil gameUtil;

  Future<void> initBody() async {
    var bodyImage = await gameUtil.assetManager.loadUiImage('images/' + 'Msh.png');
    bodyBlock = Sprite(bodyImage,
        srcPosition: Vector2(0, 0), srcSize: Vector2(479, 420));
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    bodyBlock.renderRect(canvas, Rect.fromLTWH(0, 0, 305, 268));
  }

  late Sprite bodyBlock;
}
