import 'dart:math';

import 'package:roguelike/criatura.dart';
import 'package:roguelike/entidade.dart';
import 'package:roguelike/jogador.dart';
import 'package:roguelike/mundo.dart';
import 'package:roguelike/mundo_builder.dart';
import 'package:roguelike/ponto_2d.dart';
import 'package:roguelike/roguelike.dart';
import 'package:test/test.dart';

Mundo arena() =>
    MundoBuilder(5, 5).preencher('.', false).build()
      ..jogador = Jogador(Ponto2D(2, 2), '@', 2);

// Script directions to test contact and movement without probabilistic outcomes.
class FixedRandom implements Random {
  final int direction;
  FixedRandom(this.direction);
  @override
  int nextInt(int max) => direction % max;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  test('entities retain position and display symbol', () {
    final point = Ponto2D.zero();
    point.x = 3;
    final entity = Entidade(point, 'Z');
    expect(entity.posicao.toString(), '3, 0');
    expect(entity.toString(), 'Z');
  });

  test(
    'rectangular map dimensions and all out-of-bounds positions are blocked',
    () {
      final world = MundoBuilder(7, 4).preencher('.', false).build();
      expect((world.largura, world.altura), (7, 4));
      for (final p in [(-1, 0), (0, -1), (7, 0), (0, 4)]) {
        expect(world.bloqueado(p.$1, p.$2), isTrue);
      }
      expect(world.bloqueado(6, 3), isFalse);
      expect(() => Mundo([], []), throwsArgumentError);
      expect(() => Mundo([world.mapa[0], []], []), throwsArgumentError);
    },
  );

  test('seeded random walks keep borders intact and every floor connected', () {
    for (var seed = 0; seed < 20; seed++) {
      final world = MundoBuilder(
        17,
        9,
        aleatorio: Random(seed),
      ).preencher('#', true).criarCaminho(8, 4, 400).criarCriaturas(60).build();
      final floors = <(int, int)>{};
      for (var x = 0; x < world.largura; x++) {
        for (var y = 0; y < world.altura; y++) {
          if (!world.bloqueado(x, y)) floors.add((x, y));
          if (x == 0 || y == 0 || x == 16 || y == 8) {
            expect(world.bloqueado(x, y), isTrue);
          }
        }
      }
      final visited = <(int, int)>{(8, 4)};
      final queue = <(int, int)>[(8, 4)];
      for (var i = 0; i < queue.length; i++) {
        final (x, y) = queue[i];
        for (final p in [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]) {
          if (floors.contains(p) && visited.add(p)) queue.add(p);
        }
      }
      expect(visited, floors);
      expect(world.criaturas.length, 60);
      for (final creature in world.criaturas) {
        expect(
          world.bloqueado(creature.posicao.x, creature.posicao.y),
          isFalse,
        );
      }
    }
  });

  test(
    'builder rejects invalid input and impossible spawning without hanging',
    () {
      expect(() => MundoBuilder(2, 4), throwsArgumentError);
      final builder = MundoBuilder(5, 5);
      expect(builder.build, throwsStateError);
      expect(() => builder.criarCaminho(2, 2, 0), throwsStateError);
      builder.preencher('#', true);
      expect(() => builder.criarCriaturas(1), throwsStateError);
      expect(() => builder.criarCriaturas(-1), throwsArgumentError);
      expect(() => builder.criarCaminho(0, 2, 1), throwsArgumentError);
      expect(() => builder.criarCaminho(2, 2, -1), throwsArgumentError);
      final world = builder.criarCaminho(2, 2, 0).build();
      expect(world.bloqueado(2, 2), isFalse);
      builder.mapa[2][2].bloqueado = true;
      expect(world.bloqueado(2, 2), isFalse);
    },
  );

  test('same seed reproduces dungeon, spawn positions and creature turns', () {
    final first = Roguelike(20, 12, aleatorio: Random(42)).mundo;
    final second = Roguelike(20, 12, aleatorio: Random(42)).mundo;
    for (final command in ['.', 'w', 'd', 's', 'a']) {
      expect(first.renderizar(), second.renderizar());
      first.atualizar(command);
      second.atualizar(command);
    }
    expect(first.renderizar(), second.renderizar());
  });

  test('movement commands, walls, bounds, wait and invalid input have defined turns', () {
    final world = arena();
    expect(world.atualizar(' w '), isTrue);
    expect(world.jogador.posicao.toString(), '2, 1');
    world.mapa[3][1].bloqueado = true;
    world.atualizar('d');
    expect(world.jogador.posicao.toString(), '2, 1');
    world.atualizar('a');
    world.atualizar('s');
    expect(world.jogador.posicao.toString(), '1, 2');
    world.atualizar('.');
    expect(world.jogador.passos, 5);
    expect(world.atualizar('oops'), isFalse);
    expect(world.jogador.passos, 5);
    world.jogador.posicao = Ponto2D.zero();
    world.atualizar('a');
    expect(world.jogador.posicao.toString(), '0, 0');
  });

  test(
    'creatures use all five directions and respect walls and map bounds',
    () {
      for (final (direction, destination) in [
        (0, '2, 2'),
        (1, '2, 3'),
        (2, '2, 1'),
        (3, '3, 2'),
        (4, '1, 2'),
      ]) {
        final creature = Criatura(
          Ponto2D(2, 2),
          'Z',
          aleatorio: FixedRandom(direction),
        );
        creature.atualizar(arena());
        expect(creature.posicao.toString(), destination);
      }
      final world = arena();
      final creature = Criatura(Ponto2D(2, 2), 'Z', aleatorio: FixedRandom(3));
      world.mapa[3][2].bloqueado = true;
      creature.atualizar(world);
      expect(creature.posicao.toString(), '2, 2');
      creature.posicao = Ponto2D(4, 2);
      creature.atualizar(world);
      expect(creature.posicao.toString(), '4, 2');
    },
  );

  test('damage occurs after creature movement; death stops future turns', () {
    final world = arena();
    world.criaturas.add(
      Criatura(Ponto2D(1, 2), 'Z', aleatorio: FixedRandom(3)),
    );
    expect(world.atualizar('invalid'), isFalse);
    expect(world.jogador.vidas, 2);
    world.atualizar('.');
    expect(world.jogador.vidas, 1);
    world.criaturas.clear();
    world.criaturas.addAll(
      List.generate(
        3,
        (_) => Criatura(Ponto2D(2, 2), 'Z', aleatorio: FixedRandom(0)),
      ),
    );
    world.atualizar('.');
    expect(world.jogador.vidas, 0);
    expect(world.jogador.vivo(), isFalse);
    expect(world.atualizar('w'), isFalse);
    expect(world.jogador.passos, 2);
    expect(() => world.jogador.tomarDano(-1), throwsArgumentError);
    expect(() => Jogador(Ponto2D.zero(), '@', 0), throwsArgumentError);
  });

  test(
    'rendering uses row order, player priority and optional reset ANSI codes',
    () {
      final world = MundoBuilder(3, 3).preencher('.', false).build()
        ..jogador = Jogador(Ponto2D(1, 1), '@', 2);
      world.criaturas.add(Criatura(Ponto2D(1, 1), 'Z'));
      expect(
        world.renderizar(),
        'Player: 1, 1\nLives: 2\nTurns: 0\n...\n.@.\n...\n',
      );
      expect(
        world.renderizar(colorido: true),
        contains('\u001b[34;1m@\u001b[0m'),
      );
    },
  );
}
