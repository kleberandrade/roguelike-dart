import 'dart:io';

import 'package:test/test.dart';

Future<ProcessResult> runGame(List<String> args, [String input = '']) async {
  final process = await Process.start(Platform.resolvedExecutable, [
    'run',
    'bin/main.dart',
    ...args,
  ]);
  final out = process.stdout.transform(const SystemEncoding().decoder).join();
  final err = process.stderr.transform(const SystemEncoding().decoder).join();
  process.stdin.write(input);
  await process.stdin.close();
  final code = await process.exitCode;
  return ProcessResult(process.pid, code, await out, await err);
}

void main() {
  test('help and invalid arguments exit with documented status', () async {
    final help = await runGame(['--help']);
    expect(help.exitCode, 0);
    expect(help.stdout, contains('W/A/S/D'));
    final invalid = await runGame(['--seed', 'oops']);
    expect(invalid.exitCode, 64);
    expect(invalid.stderr, contains('Usage:'));
  });

  test('EOF and Q exit gracefully; scripted input advances one turn', () async {
    final eof = await runGame(['--seed', '42']);
    expect(eof.exitCode, 0);
    expect(eof.stdout, contains('Goodbye!'));
    expect(eof.stdout, isNot(contains('\u001b[')));
    final quit = await runGame(['--seed', '42'], 'invalid\n.\nq\n');
    expect(quit.exitCode, 0);
    expect(quit.stdout, contains('Unknown command.'));
    expect(quit.stdout, contains('Turns: 1'));
    expect(quit.stdout, contains('Goodbye!'));
    expect(quit.stderr, isEmpty);
  });
  test('scripted waits reach game over and report zero lives', () async {
    final result = await runGame(['--seed', '42'], '.\n' * 1000);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('Lives: 0'));
    expect(result.stdout, contains('Game over after'));
    expect(result.stderr, isEmpty);
  });
}
