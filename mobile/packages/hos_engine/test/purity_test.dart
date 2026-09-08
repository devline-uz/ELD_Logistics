// M44 — paket sofligi: flutter bog'liqligi yo'q, I/O yo'q, global holat yo'q,
// `DateTime.now()` yo'q. Bu testlar CI `hos-parity` job'ining Dart yarmi.
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

const _forbiddenPackages = <String>['flutter', 'flutter_test', 'flutter_lints', 'sky_engine'];

List<File> _libFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList(growable: false);

void main() {
  test('pubspec.yaml declares no flutter dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final name in _forbiddenPackages) {
      expect(
        RegExp('^\\s*$name\\s*:', multiLine: true).hasMatch(pubspec),
        isFalse,
        reason: '$name must not appear in pubspec.yaml (M44)',
      );
    }
  });

  test('dart pub deps --json contains no flutter package', () {
    final r = Process.runSync(Platform.resolvedExecutable, <String>[
      'pub',
      'deps',
      '--json',
    ], workingDirectory: Directory.current.path);
    expect(r.exitCode, 0, reason: '${r.stderr}');
    final json = (jsonDecode(r.stdout as String) as Map).cast<String, dynamic>();
    final names = (json['packages'] as List).map((e) => ((e as Map)['name'] as String)).toSet();
    for (final name in _forbiddenPackages) {
      expect(names, isNot(contains(name)), reason: 'M44');
    }
    // Yagona ruxsat etilgan runtime bog'liqliklar.
    final direct = (json['packages'] as List)
        .where((e) => (e as Map)['kind'] == 'direct')
        .map((e) => (e as Map)['name'] as String)
        .toSet();
    expect(direct, <String>{'meta', 'timezone'});
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('lib/ uses no dart:ui, dart:io, dart:html or dart:isolate', () {
    final bad = <String>[];
    for (final f in _libFiles()) {
      final src = f.readAsStringSync();
      for (final lib in <String>['dart:ui', 'dart:io', 'dart:html', 'dart:isolate']) {
        if (src.contains("'$lib'") || src.contains('"$lib"')) {
          bad.add('${f.path}: $lib');
        }
      }
    }
    expect(bad, isEmpty);
  });

  test('lib/ never calls DateTime.now() or Random()', () {
    final bad = <String>[];
    for (final f in _libFiles()) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i];
        final t = l.trimLeft();
        if (t.startsWith('//') || t.startsWith('*')) continue; // izohlar
        if (l.contains('DateTime.now()') ||
            RegExp(r'\bRandom\(').hasMatch(l) ||
            l.contains('print(')) {
          bad.add('${f.path}:${i + 1}: ${l.trim()}');
        }
      }
    }
    expect(bad, isEmpty, reason: 'time is always a parameter (M44)');
  });

  test('lib/ declares no mutable top-level state', () {
    final bad = <String>[];
    final decl = RegExp(r'^(?!\s)(?:var|late|[A-Za-z_<>,?\s]+)\s+\w+\s*=');
    for (final f in _libFiles()) {
      for (final l in f.readAsLinesSync()) {
        if (l.startsWith('var ') || l.startsWith('late ')) {
          bad.add('${f.path}: $l');
        } else if (decl.hasMatch(l) &&
            !l.startsWith('const ') &&
            !l.startsWith('final ') &&
            !l.startsWith('typedef ')) {
          bad.add('${f.path}: $l');
        }
      }
    }
    expect(bad, isEmpty, reason: 'no global mutable state (M44)');
  });
}
