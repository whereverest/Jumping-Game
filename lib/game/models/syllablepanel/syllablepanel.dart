import 'package:flame/components.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';
import 'syllablebutton.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class SyllablePanel extends SpriteAnimationComponent {
  final JSGame jsGame;
  SyllablePanel({required this.jsGame, required this.width, required this.height}) : super(size: Vector2(width, height));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    syllableButtonList.add(SyllableButton(jsGame: jsGame, syllable: 3, isTappable: true));
    syllableButtonList.add(SyllableButton(jsGame: jsGame, syllable: 2, isTappable: true));
    syllableButtonList.add(SyllableButton(jsGame: jsGame, syllable: 1, isTappable: true));

    for (int i = 0; i < 3; ++ i) {
      syllableButtonList[i].position = Vector2(0, (height - 3 * 100 * jsGame.widthRatio - 10) / 2 + 100 * jsGame.widthRatio * i + 5 * i);
      syllableButtonList[i].initButton().then((value) => { add(syllableButtonList[i]) });
    }
  }

  void moveLeftLinear() {
    for (int i = 0; i < 3; ++ i) {
      syllableButtonList[i].currentTimerPlaying = 0;
      syllableButtonList[i].animationType = SyButtonAnimationType.MoveLeftLinear;
    }
  }

  void moveRightLinearParticular(int rightSelectedSyllable) {
    for (int i = 0; i < 3; ++ i) {
      if (syllableButtonList[i].syllable == rightSelectedSyllable) {
        syllableButtonList[i].currentTimerPlaying = 0;
        syllableButtonList[i].animationType = SyButtonAnimationType.MoveRightLinear;
      }
    }

    jsGame.jsAudioManager.playUISound("Syllable-buttons-slide-out.mp3");
  }

  void moveRightLinear(int rightSelectedSyllable) {
    for (int i = 0; i < 3; ++ i) {
      if (syllableButtonList[i].syllable != rightSelectedSyllable) {
        syllableButtonList[i].currentTimerPlaying = 0;
        syllableButtonList[i].animationType = SyButtonAnimationType.MoveRightLinear;
      }
      else {
        syllableButtonList[i].currentTimerPlaying = 0;
        syllableButtonList[i].animationType = SyButtonAnimationType.NotifyWithZoom;
      }
    }

    jsGame.jsAudioManager.playUISound("Syllable-buttons-slide-out.mp3");
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  final double width;
  final double height;
  List<SyllableButton> syllableButtonList = [];
}