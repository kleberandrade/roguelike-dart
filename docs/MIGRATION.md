# Migrating from Dart 2

Version 1.1.0 preserves the package name `roguelike`, Portuguese model names,
`lib/` imports and `bin/main.dart` entry point. No Flutter dependency is added.

1. Install current stable Dart (minimum 3.14.0, below 4.0.0).
2. Run `dart pub get --enforce-lockfile` from the root. Keep the lockfile checked
   in because this repository is an application.
3. Use `dart run bin/main.dart` or build a native executable as in the README.
4. Update code that expected player/world updates to read standard input.
   Only `Roguelike.executar()` now reads terminal commands. Call
   `world.atualizar('w')` for a full turn, or `world.atualizar()` to wait.
   `Jogador.atualizar(world)` now waits without advancing creatures.

## Intentional behavior changes

- The default map is 80 × 24 instead of 160 × 40 to fit ordinary terminals.
- Q and EOF quit cleanly. Invalid input no longer spends a turn. Wall bumps
  still spend turns. `passos` is labeled **Turns** because it counts attempts.
- Lives are clamped to zero and negative damage is rejected.
- Out-of-range moves are blocked instead of throwing indexing errors.
- Zero-step paths open their initial tile. Invalid dimensions, path origins,
  negative counts and impossible creature spawning fail immediately.
- Random generators can be injected. Generation and seeded layouts differ from
  the old implementation; historical random maps are not reproduced.
- ANSI output is optional and reset after each actor. Redirected CLI output is
  plain text. Terminal messages and repository documentation are now English.
- `Mundo` rejects empty/ragged maps. Builder dimensions are final; create a new
  builder to change dimensions. Re-filling clears builder creatures.
- Constants are compile-time constants; their original names remain, including
  the historical spelling `QUANTIDADE_CRIATUDAS`.

The collision rule is retained: damage is checked after each creature moves,
not on the player's initial contact with a creature. Actors may overlap. There
is no new combat, treasure, persistence or dependency on another project.

## Tooling

The project uses sound null safety and maintained `lints` instead of deprecated
`pedantic`. CI resolves the committed lockfile, checks formatting and static
analysis, runs the tests and example, compiles the CLI and checks startup/quit.
When updating dependencies, run `dart pub outdated`, update constraints and
lockfile deliberately, then repeat these checks.
