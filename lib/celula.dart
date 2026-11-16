import 'package:roguelike/entidade.dart';

/// A wall or floor tile at a map coordinate.
class Celula extends Entidade {
  bool bloqueado;

  Celula(super.posicao, super.simbolo, this.bloqueado);
}
