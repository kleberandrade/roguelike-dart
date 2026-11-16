import 'dart:math';

import 'package:roguelike/celula.dart';
import 'package:roguelike/criatura.dart';
import 'package:roguelike/mundo.dart';
import 'package:roguelike/ponto_2d.dart';

/// Builds a connected random-walk dungeon, retaining its outer walls.
class MundoBuilder {
  static const String SIMBOLO_PASSAGEM = '.';
  final int largura, altura;
  final Random _aleatorio;
  List<List<Celula>> mapa = [];
  List<Criatura> criaturas = [];

  MundoBuilder(this.largura, this.altura, {Random? aleatorio})
    : _aleatorio = aleatorio ?? Random() {
    if (largura < 3 || altura < 3) {
      throw ArgumentError('World dimensions must be at least 3 by 3');
    }
  }

  void _verificarMapa() {
    if (mapa.isEmpty) {
      throw StateError('Call preencher before building a world');
    }
  }

  MundoBuilder preencher(String simbolo, bool bloqueado) {
    mapa = List.generate(
      largura,
      (x) => List.generate(
        altura,
        (y) => Celula(Ponto2D(x, y), simbolo, bloqueado),
      ),
    );
    criaturas = [];
    return this;
  }

  MundoBuilder criarCaminho(int x, int y, int passos) {
    _verificarMapa();
    if (x <= 0 || y <= 0 || x >= largura - 1 || y >= altura - 1) {
      throw ArgumentError('The path must start inside the outer walls');
    }
    if (passos < 0) throw ArgumentError.value(passos, 'passos');
    // Even a zero-step walk opens the spawn cell.
    mapa[x][y] = Celula(Ponto2D(x, y), SIMBOLO_PASSAGEM, false);
    for (var i = 0; i < passos; i++) {
      switch (_aleatorio.nextInt(4)) {
        case 0:
          if (x < largura - 2) x++;
        case 1:
          if (x > 1) x--;
        case 2:
          if (y < altura - 2) y++;
        case 3:
          if (y > 1) y--;
      }
      mapa[x][y] = Celula(Ponto2D(x, y), SIMBOLO_PASSAGEM, false);
    }
    return this;
  }

  MundoBuilder criarCriaturas(int quantidadeCriaturas) {
    _verificarMapa();
    if (quantidadeCriaturas < 0) {
      throw ArgumentError.value(quantidadeCriaturas, 'quantidadeCriaturas');
    }
    final passagens = [
      for (final coluna in mapa)
        for (final celula in coluna)
          if (!celula.bloqueado) celula.posicao,
    ];
    if (quantidadeCriaturas > 0 && passagens.isEmpty) {
      throw StateError('Cannot spawn creatures without a walkable cell');
    }
    for (var i = 0; i < quantidadeCriaturas; i++) {
      final posicao = passagens[_aleatorio.nextInt(passagens.length)];
      criaturas.add(
        Criatura(
          Ponto2D(posicao.x, posicao.y),
          Criatura.SIMBOLO_CRIATURA,
          aleatorio: Random(_aleatorio.nextInt(1 << 32)),
        ),
      );
    }
    return this;
  }

  Mundo build() {
    _verificarMapa();
    // Keep later builder calls from mutating an already built world.
    return Mundo([
      for (final coluna in mapa)
        [
          for (final c in coluna)
            Celula(Ponto2D(c.posicao.x, c.posicao.y), c.simbolo, c.bloqueado),
        ],
    ], List.of(criaturas));
  }
}
