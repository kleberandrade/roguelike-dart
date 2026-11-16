import 'dart:math';

import 'package:roguelike/jogador.dart';
import 'package:roguelike/mundo_builder.dart';
import 'package:roguelike/ponto_2d.dart';

/// Build, render and advance a small dungeon without interactive input.
void main() {
  final world =
      MundoBuilder(20, 10, aleatorio: Random(42))
          .preencher('#', true)
          .criarCaminho(10, 5, 200)
          .criarCriaturas(3)
          .build()
        ..jogador = Jogador(Ponto2D(10, 5), '@', 2);
  print(world.renderizar());
  for (final command in ['w', 'd', '.', 'a']) {
    if (!world.jogador.vivo()) break;
    world.atualizar(command);
  }
  print(world.renderizar());
}
