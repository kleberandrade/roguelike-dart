import 'package:roguelike/mundo.dart';
import 'package:roguelike/personagem.dart';

class Jogador extends Personagem {
  static const String TECLA_CIMA = 'W';
  static const String TECLA_BAIXO = 'S';
  static const String TECLA_DIREITA = 'D';
  static const String TECLA_ESQUERDA = 'A';
  static const String SIMBOLO_JOGADOR = '@';

  int _vidas;
  int passos = 0;
  int get vidas => _vidas;

  Jogador(super.posicao, super.simbolo, this._vidas) {
    if (_vidas <= 0) {
      throw ArgumentError.value(_vidas, 'vidas', 'Must be positive');
    }
  }

  bool vivo() => _vidas > 0;

  void tomarDano(int dano) {
    if (dano < 0) {
      throw ArgumentError.value(dano, 'dano', 'Must be non-negative');
    }
    _vidas = (_vidas - dano).clamp(0, _vidas);
  }

  /// A movement attempt (including a wall bump) or wait consumes one turn.
  /// Invalid commands do not move the player or advance creatures.
  bool processarComando(Mundo mundo, String comando) {
    if (!vivo()) return false;
    final delta = switch (comando.trim().toUpperCase()) {
      TECLA_CIMA => (0, -1),
      TECLA_BAIXO => (0, 1),
      TECLA_DIREITA => (1, 0),
      TECLA_ESQUERDA => (-1, 0),
      '.' => (0, 0),
      _ => null,
    };
    if (delta == null) return false;
    mover(mundo, delta.$1, delta.$2);
    passos++;
    return true;
  }

  /// The player waits when updated without an explicit command.
  @override
  void atualizar(Mundo mundo) => processarComando(mundo, '.');
}
