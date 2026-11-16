# API and extension notes

## Model

- `Ponto2D(x, y)` and `Ponto2D.zero()` are mutable coordinates. Compare `x` and
  `y` for coordinate equality; points retain identity equality and should not
  be used as mutable map keys. `toString()` produces `x, y`.
- `Entidade` owns a position and symbol. `Celula` adds `bloqueado`.
- `Personagem` defines `atualizar(Mundo)` and `mover(Mundo, dx, dy)`.
  The latter checks only its destination; callers implementing new movement
  rules should use single-cell cardinal deltas or check intermediate tiles.
- `Jogador` holds lives and accepted turns (`passos`). Initial lives must be
  positive. Damage must be non-negative and is clamped at zero lives.
- `Criatura` accepts an optional `Random aleatorio`. Supply a seeded generator
  or a scripted `Random` in tests. Its five actions are equally likely.

## World construction

`MundoBuilder(width, height, aleatorio: random)` requires dimensions of at least
3 × 3. Chain `preencher`, `criarCaminho`, `criarCriaturas`, then `build`.

`preencher` replaces tiles and clears the builder's creature list. Path carving
requires an interior starting cell and non-negative step count; it opens the
starting cell even for zero steps. It never carves the outer border.
Creature counts must be non-negative. Spawning without any floor throws
`StateError` immediately. Spawn selection uses replacement, so multiple actors
can share a floor cell. Spawned creatures receive independent positions and
random generators derived from the builder generator.

`build` requires a filled map. It copies tiles and the creature list; existing
creature objects are shared, so avoid using one builder to produce independent
simulation snapshots. The constructor `Mundo(map, creatures)` accepts any
non-empty rectangular column-major map, including maps smaller than the builder
minimum, and retains the supplied collections. Direct mutations are supported
for teaching experiments; callers are responsible for keeping them rectangular
and placing actors on valid cells.

Attach `world.jogador` before calling `atualizar`, `renderizar` or `desenhar`.
Otherwise Dart reports a `LateInitializationError`. `Roguelike` handles this
attachment automatically and exposes its world through `mundo`.

## Turn processing

`world.atualizar(command)` returns `true` for accepted turns and `false` for
invalid commands or an already-dead player. Its default command is `.`. The
world delegates command parsing to `Jogador.processarComando`, then updates each
creature in insertion order and applies contact damage after each creature's
move. All creatures complete the accepted turn even if lives reach zero midway.
Calling `processarComando` directly updates only the player; use the world method
to run a complete turn. `Jogador.atualizar(world)` performs a player-only wait.

`Roguelike(width, height, aleatorio: Random(seed))` creates the default game.
`criarMundo()` starts a fresh game using the next values in the same generator;
it does not rewind the seed. `executar()` owns blocking line-based terminal I/O.
Keep noninteractive callers on `Mundo.atualizar` instead.

A seed reproduces behavior for the same SDK, settings and command sequence.
Dart's random algorithm is not a durable cross-version save-game format.

## Rendering and extensions

`renderizar(colorido: false)` returns status and the map as one string. Actor
symbols overlay terrain and the player has priority. `desenhar` prints that
string. The CLI requests color only when stdout is an ANSI-capable terminal.

Subclass `Criatura` and override `atualizar` for new NPC behavior, then add it to
`world.criaturas`. Use `mover` to respect walls and bounds. Treasure and combat
require explicit new rules: the existing actor overlap represents damage to
the player, not attacks on creatures. Cover those rules with deterministic tests.
