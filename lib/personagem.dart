import 'package:roguelike/entidade.dart';
import 'package:roguelike/mundo.dart';

/// Base class for player-controlled and autonomous actors.
abstract class Personagem extends Entidade {
  Personagem(super.posicao, super.simbolo);

  /// Apply a displacement if its destination is walkable.
  /// Game controls use single-cell orthogonal moves; this primitive accepts
  /// arbitrary deltas and only checks the destination, not intermediate cells.
  void mover(Mundo mundo, int deltaX, int deltaY) {
    if (!mundo.bloqueado(posicao.x + deltaX, posicao.y + deltaY)) {
      posicao.x += deltaX;
      posicao.y += deltaY;
    }
  }

  void atualizar(Mundo mundo);
}
