import 'package:flame/components.dart';
import 'package:jumping_syllables/game/models/cardpanel/card.dart';
import 'package:jumping_syllables/game/screens/jsgame.dart';

class BoardCard extends PositionComponent with HasGameRef {
  BoardCard({required this.jsGame, required this.widthRatio, required this.heightRatio, required this.text, required this.syllable, required this.structure}) : super(size: Vector2.all(140.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    card = Card(
      jsGame: jsGame,
      text: text,
      syllable: syllable,
      structure: structure,
      width: 100,
      height: 100,
      isTappable: true
    );
    await add(card);
  }

  @override
  void update(double delta) {
    super.update(delta);
  }

  final String text;
  final int syllable;
  final String structure;
  final JSGame jsGame;
  late Card card;
  final double widthRatio;
  final double heightRatio;
  double opacity = 1;
}