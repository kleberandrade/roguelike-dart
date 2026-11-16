import 'package:roguelike/ponto_2d.dart';

/// A visible object with a mutable position and display symbol.
class Entidade {
  Ponto2D posicao;
  String simbolo;

  Entidade(this.posicao, this.simbolo);

  @override
  String toString() => simbolo;
}
