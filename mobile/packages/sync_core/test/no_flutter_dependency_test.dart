// M4: `sync_core` must stay pure Dart — no direct or transitive Flutter
// dependency, and no wall-clock / insecure-random calls inside `lib/`.
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('pubspec declares no flutter dependency', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final Iterable<String> lines = pubspec
        .split('\n')
        .where((String l) => !l.trimLeft().startsWith('#'));
    expect(lines.any((String l) => RegExp(r'^\s*flutter\s*:').hasMatch(l)), isFalse);
    expect(pubspec.contains('sdk: flutter'), isFalse);
  });

  test('the resolved dependency graph contains no flutter package', () {
    final File lock = File('pubspec.lock');
    expect(lock.existsSync(), isTrue, reason: 'run `dart pub get` first');
    expect(lock.readAsStringSync().contains('\n  flutter:\n'), isFalse);
  });

  test('lib/ never imports flutter and never reads the wall clock', () {
    final List<File> sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();
    expect(sources, isNotEmpty);

    for (final File file in sources) {
      final List<String> code = file
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('///') && !l.trimLeft().startsWith('//'))
          .toList();
      final String body = code.join('\n');
      expect(body.contains('package:flutter/'), isFalse, reason: file.path);
      expect(body.contains('dart:io'), isFalse, reason: file.path);
      expect(body.contains('dart:ui'), isFalse, reason: file.path);
      expect(body.contains('DateTime.now()'), isFalse, reason: file.path);
      expect(RegExp(r'[^.\w]Random\(\)').hasMatch(body), isFalse, reason: file.path);
    }
  });
}
