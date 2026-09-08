import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

void main() {
  group('formatUuidV4', () {
    test('sets the version and variant nibbles', () {
      final String uuid = formatUuidV4(List<int>.filled(16, 0));
      expect(uuid, '00000000-0000-4000-8000-000000000000');
      expect(isUuidV4(uuid), isTrue);
    });

    test('keeps the remaining entropy and stays canonical', () {
      final String uuid = formatUuidV4(List<int>.generate(16, (int i) => i * 16 + i));
      expect(uuid, '00112233-4455-4677-8899-aabbccddeeff');
      expect(isUuidV4(uuid), isTrue);
    });

    test('all-ones input still yields a valid v4', () {
      final String uuid = formatUuidV4(List<int>.filled(16, 0xff));
      expect(isUuidV4(uuid), isTrue);
      expect(uuid, 'ffffffff-ffff-4fff-bfff-ffffffffffff');
    });

    test('rejects a wrong length', () {
      expect(() => formatUuidV4(<int>[1, 2, 3]), throwsArgumentError);
      expect(() => formatUuidV4(List<int>.filled(17, 0)), throwsArgumentError);
    });

    test('rejects non-byte values', () {
      final List<int> bad = List<int>.filled(16, 0)..[3] = 256;
      expect(() => formatUuidV4(bad), throwsArgumentError);
      final List<int> negative = List<int>.filled(16, 0)..[0] = -1;
      expect(() => formatUuidV4(negative), throwsArgumentError);
    });

    test('does not mutate the caller list', () {
      final List<int> input = List<int>.filled(16, 0xff);
      formatUuidV4(input);
      expect(input.every((int b) => b == 0xff), isTrue);
    });
  });
}
