import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';

class InvisibleTappable extends PositionComponent with HasGameRef, Tappable {
  InvisibleTappable({required this.jsGame}) : super();

  @override
  bool onTapUp(TapUpInfo info) {
    if (jsGame.machine.syllable != 0) {
      if (jsGame.joyAudioList.contains(jsGame.machine.structure)) {
        jsGame.joy.simpleClapAndSay(true);
        jsGame.woof.simpleClapAndSay(false);
      }
      if (jsGame.woofAudioList.contains(jsGame.machine.structure)) {
        jsGame.joy.simpleClapAndSay(false);
        jsGame.woof.simpleClapAndSay(true);
      }
    }
    return super.onTapUp(info);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  final JSGame jsGame;
}