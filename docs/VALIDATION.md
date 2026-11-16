# Validation record

Validated locally with standalone **Dart 3.14.0 stable**, macOS ARM64.
The project-local SDK used for this run is ignored under `.tooling/dart-sdk`;
Flutter and its older bundled SDK were not changed.

Successful checks (commands below assume `dart` resolves to 3.14.0):

```sh
dart pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib bin example test
dart analyze --fatal-infos
dart test
dart run example/seeded_world.dart
mkdir -p build
dart compile exe bin/main.dart -o build/roguelike
dart pub outdated
```

- Dependency resolution respects the committed lockfile; no outdated packages.
- All 13 Dart files pass formatting; analysis reports no issues.
- All 12 tests pass, including generated-map invariants over 20 seeds and CLI
  subprocess checks for help, invalid arguments, EOF, quit, turns and game over.
- The example prints its initial and final 20 × 10 maps and completes four turns.
- The native executable starts and exits successfully on Q and EOF. A seeded
  sequence of waits reaches zero lives and game over (12 turns with seed 42 on
  this SDK). Invalid seed input returns status 64.
- A PTY session was exercised: startup, one wait turn, updated status and Q.
- Redirected output contains no ANSI escape sequences.

The GitHub Actions workflow is provided for Linux but has not been run remotely.
Windows and Linux were not executed locally; their commands are documented for
standard Dart CLI usage. The VS Code terminal launch configuration was updated
but not exercised through the editor UI. Random sequences are only reproducible
within the same SDK and settings; the tests do not promise cross-version maps.
