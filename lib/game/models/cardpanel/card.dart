import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:jumping_syllables/game/models/cardpanel/carditem.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';
import 'package:jumping_syllables/game/constants/enumerations.dart';

class Card extends PositionComponent with HasGameRef, Tappable, Draggable {
  final JSGame jsGame;

  Card(
      {required this.jsGame,
      required this.text,
      required this.syllable,
      required this.structure,
      required this.width,
      required this.height,
      required this.isTappable})
      : super(size: Vector2(width, height));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    cardItem = CardItem(
      widthRatio: jsGame.widthRatio,
      heightRatio: jsGame.heightRatio,
      text: text,
      syllable: syllable,
      width: width,
      height: height,
      gameUtil: jsGame.gameUtil,
    );
    await add(cardItem);
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  final String text;
  final int syllable;
  final String structure;
  final double width;
  final double height;
  final bool isTappable;
  late CardItem cardItem;
  bool isInBoard = false;
  Vector2? dragDeltaPosition;

  bool get isDragging => dragDeltaPosition != null;
  late Vector2 original;

  void notifyWithZoom() {
    cardItem.notifyWithZoom();
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (isTappable) {
      if (jsGame.joyAudioList.contains(structure)) {
        jsGame.jsAudioManager.sayWord("JOY", structure);
        jsGame.joy.speak();
      }
      if (jsGame.woofAudioList.contains(structure)) {
        jsGame.jsAudioManager.sayWord("WOOF", structure);
        jsGame.woof.speak();
      }
      print("[DEBUG] - tapped in card, structure is: " + structure);
      jsGame.hand.opacity = 0;
      jsGame.removeTimerComponent();
    }
    return super.onTapUp(info);
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo startPosition) {
    if (isTappable) {
      jsGame.setDraggingIndex(syllable);
      original = position.clone();
      dragDeltaPosition = startPosition.eventPosition.global - position;
    }
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo event) {
    if (isTappable) {
      final localCoords = event.eventPosition.game;
      Vector2 boardPos = jsGame.machine.position + Vector2(150, -10);
      Vector2 eventPos = event.eventPosition.global;

      isInBoard = false;
      if (boardPos.x - 50 <= eventPos.x && boardPos.x + 150 >= eventPos.x) {
        if (boardPos.y - 50 <= eventPos.y && boardPos.y + 150 >= eventPos.y)
          isInBoard = true;
      }

      position = localCoords - dragDeltaPosition!;
    }
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo event) {
    if (isTappable) {
      dragDeltaPosition = null;

      if (isInBoard) {
        print("[DEBUG] - machine status when card is going to be on machine: " +
            jsGame.machine.machineAnimationStatus.toString());
        jsGame.cardPanel.removeCard(this);
        jsGame.machine.addCard(this);
        jsGame.hand.opacity = 0;
        jsGame.removeTimerComponent();
        jsGame.removeCardPanel();
        jsGame.initSyllablePanel();
        jsGame.syllablePanel.moveLeftLinear();
        jsGame.removeHandComponent();
        jsGame.addHandComponent();
        jsGame.addTimerComponent(HandAnimationType.HandIndicationAnimation);

        if (jsGame.wordStep % 3 == 0) {
          jsGame.jsAudioManager.speak("WJ", "How-many-syllables-are.mp3");
          jsGame.joy.askQuestion();
          jsGame.woof.askQuestion();
        } else {
          if (jsGame.joyAudioList.contains(jsGame.machine.structure)) {
            jsGame.joy.speak();
            jsGame.jsAudioManager.sayWord("JOY", structure);
          }
          if (jsGame.woofAudioList.contains(jsGame.machine.structure)) {
            jsGame.woof.speak();
            jsGame.jsAudioManager.sayWord("WOOF", structure);
          }
        }

        print("[DEBUG] - when joy says how many syllables are, it's " +
            jsGame.stageStatus.toString());
      } else {
        position = original.clone();
      }
    }
    return false;
  }

  @override
  bool onDragCancel(int pointerId) {
    dragDeltaPosition = null;
    return false;
  }
}
