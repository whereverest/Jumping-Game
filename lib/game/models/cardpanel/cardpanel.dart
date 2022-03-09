import 'package:flame/components.dart';
import 'package:jumping_syllables/game/models/cardpanel/card.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';
import 'package:jumping_syllables/game/models/syllablepanel/syllabledata.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';


class CardPanel extends SpriteAnimationComponent {
  final JSGame jsGame;
  CardPanel({required this.jsGame, required this.width, required this.height}) : super(size: Vector2(width, height));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    dataSource = SyllableData(false);
  }

  void reloadDataSource() {
    dataSource = SyllableData(false);
    print(jsGame.isFirstRun);
  }

  Future<void> initBackground() async {
    addCards();
  }

  void addCards() async {
    List<SyllableDataItem> fSD = dataSource.finalSyllableData;
    int wordStep = jsGame.wordStep;

    rightCount = 0;
    cardList.clear();

    for (int i = 0; i < 3; ++ i) {
      cardList.add(
          Card(
            jsGame: jsGame,
            text: fSD[wordStep + i].word,
            syllable: fSD[wordStep + i].syllable,
            structure: fSD[wordStep + i].structure,
            width: 120,
            height: 120,
            isTappable: true
          )
      );

      cardList[i].position = Vector2(
          jsGame.size.x + 200,
          (height - 3 * 108 * jsGame.widthRatio - 5) / 2 + i * (108 * jsGame.widthRatio + 2.5)
      );
      await jsGame.add(cardList[i]);
    }

    jsGame.setDraggingIndex(0);
  }

  bool isCardListNotEmpty() {
    for (int i = 0; i < 3; ++ i) {
      if (cardList[i].isInBoard == false)
        return true;
    }
    return false;
  }
  void increaseRightCount() { rightCount = rightCount + 1; }

  void removeCard(Card card) {
    jsGame.remove(card);
    //cardList.remove(card);
  }

  @override
  void update(double delta) {
    super.update(delta);

    if (cardPanelAnimationType == CardPanelAnimationType.SlideIn) {
      currentTimerPlaying += delta;

      double movingDistance = -(150 * jsGame.widthRatio + 180) * delta;
      if (currentTimerPlaying >= 0 && currentTimerPlaying < 1) {
        //position.add(Vector2(movingDistance * delta, 0));
        for (int i = 0; i < cardList.length; ++ i)
          cardList[i].position.x += movingDistance;
      }
      else {
        //position = Vector2(jsGame.size.x - 150 * jsGame.widthRatio, 0);
        for (int i = 0; i < cardList.length; ++ i)
          cardList[i].position.x = jsGame.size.x - 150 * jsGame.widthRatio + 20;
        currentTimerPlaying = 0;
        cardPanelAnimationType = CardPanelAnimationType.None;
      }
    }
  }

  final double width;
  final double height;
  List<Card> cardList = [];
  CardPanelAnimationType cardPanelAnimationType = CardPanelAnimationType.None;
  double currentTimerPlaying = 0;
  int rightCount = 0;
  late SyllableData dataSource;
}