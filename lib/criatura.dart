import 'dart:math';

import 'package:roguelike/mundo.dart';
import 'package:roguelike/personagem.dart';

/// A creature that chooses uniformly between waiting and four cardinal moves.
class Criatura extends Personagem {
  static const int FICAR_PARADO = 0;
  static const int MOVER_BAIXO = 1;
  static const int MOVER_CIMA = 2;
  static const int MOVER_DIREITA = 3;
  static const int MOVER_ESQUERDA = 4;
  static const int QUANTIDADE_MOVIMENTOS = 5;
  static const String SIMBOLO_CRIATURA = 'Z';

  final Random _aleatorio;

  Criatura(super.posicao, super.simbolo, {Random? aleatorio})
    : _aleatorio = aleatorio ?? Random();

  @override
  void atualizar(Mundo mundo) {
    switch (_aleatorio.nextInt(QUANTIDADE_MOVIMENTOS)) {
      case FICAR_PARADO:
        mover(mundo, 0, 0);
      case MOVER_BAIXO:
        mover(mundo, 0, 1);
      case MOVER_CIMA:
        mover(mundo, 0, -1);
      case MOVER_DIREITA:
        mover(mundo, 1, 0);
      case MOVER_ESQUERDA:
        mover(mundo, -1, 0);
    }
  }
}
