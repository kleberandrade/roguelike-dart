import 'dart:io';
import 'dart:math';

import 'package:roguelike/roguelike.dart';

void main(List<String> args) {
  if (args.contains('--help')) {
    print('Usage: dart run bin/main.dart [--seed INTEGER]');
    print('W/A/S/D + Enter: move | .: wait | Q: quit');
    return;
  }
  int? seed;
  if (args.isNotEmpty) {
    if (args.length != 2 ||
        args.first != '--seed' ||
        (seed = int.tryParse(args[1])) == null) {
      stderr.writeln('Usage: dart run bin/main.dart [--seed INTEGER]');
      exitCode = 64;
      return;
    }
  }
  Roguelike(80, 24, aleatorio: Random(seed)).executar();
}
