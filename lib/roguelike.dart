import 'dart:io';
import 'dart:math';

import 'package:roguelike/jogador.dart';
import 'package:roguelike/mundo.dart';
import 'package:roguelike/mundo_builder.dart';
import 'package:roguelike/ponto_2d.dart';

class Roguelike {
  static const String SIMBOLO_PAREDE = '#';
  static const int QUANTIDADE_CRIATUDAS = 60;
  static const int QUANTIDADE_VIDAS = 2;
  static const double FATOR_PROFUNDIDADE = 2.0;

  late Mundo _mundo;
  final int _largura, _altura;
  final Random _aleatorio;
  Mundo get mundo => _mundo;

  Roguelike(this._largura, this._altura, {Random? aleatorio})
    : _aleatorio = aleatorio ?? Random() {
    criarMundo();
  }

  void criarMundo() {
    final posicao = Ponto2D(_largura ~/ 2, _altura ~/ 2);
    _mundo = MundoBuilder(_largura, _altura, aleatorio: _aleatorio)
        .preencher(SIMBOLO_PAREDE, true)
        .criarCaminho(
          posicao.x,
          posicao.y,
          (_largura * _altura * FATOR_PROFUNDIDADE).toInt(),
        )
        .criarCriaturas(QUANTIDADE_CRIATUDAS)
        .build();
    _mundo.jogador = Jogador(
      posicao,
      Jogador.SIMBOLO_JOGADOR,
      QUANTIDADE_VIDAS,
    );
  }

  /// Read one command per line. Q or EOF exits without advancing a turn.
  void executar() {
    while (_mundo.jogador.vivo()) {
      _mundo.desenhar(
        colorido: stdout.hasTerminal && stdout.supportsAnsiEscapes,
      );
      stdout.writeln('W/A/S/D + Enter: move | .: wait | Q: quit');
      final entrada = stdin.readLineSync();
      if (entrada == null || entrada.trim().toUpperCase() == 'Q') {
        stdout.writeln('Goodbye!');
        return;
      }
      if (!_mundo.atualizar(entrada)) stdout.writeln('Unknown command.');
    }
    _mundo.desenhar(colorido: stdout.hasTerminal && stdout.supportsAnsiEscapes);
    stdout.writeln('Game over after ${_mundo.jogador.passos} turns!');
  }
}
