import 'package:roguelike/celula.dart';
import 'package:roguelike/criatura.dart';
import 'package:roguelike/jogador.dart';
import 'package:roguelike/personagem.dart';

/// A rectangular, column-major map and its actors.
class Mundo {
  final List<List<Celula>> mapa;
  final List<Criatura> criaturas;
  late Jogador jogador;

  Mundo(this.mapa, this.criaturas) {
    if (mapa.isEmpty ||
        mapa.first.isEmpty ||
        mapa.any((coluna) => coluna.length != mapa.first.length)) {
      throw ArgumentError('The map must be non-empty and rectangular');
    }
  }

  int get largura => mapa.length;
  int get altura => mapa.first.length;

  /// Coordinates outside the map are always blocked.
  bool bloqueado(int x, int y) =>
      x < 0 || y < 0 || x >= largura || y >= altura || mapa[x][y].bloqueado;

  /// Move the player first, then every creature. A creature deals one damage
  /// when it ends its turn on the player's cell; actors may share cells.
  bool atualizar([String comando = '.']) {
    if (!jogador.processarComando(this, comando)) return false;
    for (final criatura in criaturas) {
      criatura.atualizar(this);
      if (criatura.posicao.x == jogador.posicao.x &&
          criatura.posicao.y == jogador.posicao.y) {
        jogador.tomarDano(1);
      }
    }
    return true;
  }

  /// Render without terminal side effects; the player takes visual priority.
  String renderizar({bool colorido = false}) {
    final atores = <String, Personagem>{
      for (final criatura in criaturas) criatura.posicao.toString(): criatura,
      jogador.posicao.toString(): jogador,
    };
    final saida = StringBuffer()
      ..writeln('Player: ${jogador.posicao}')
      ..writeln('Lives: ${jogador.vidas}')
      ..writeln('Turns: ${jogador.passos}');
    for (var y = 0; y < altura; y++) {
      for (var x = 0; x < largura; x++) {
        final ator = atores['$x, $y'];
        if (colorido && ator != null) {
          saida.write(
            identical(ator, jogador) ? '\u001b[34;1m' : '\u001b[31;1m',
          );
        }
        saida.write(ator?.simbolo ?? mapa[x][y].simbolo);
        if (colorido && ator != null) saida.write('\u001b[0m');
      }
      saida.writeln();
    }
    return saida.toString();
  }

  void desenhar({bool colorido = false}) =>
      print(renderizar(colorido: colorido));
}
