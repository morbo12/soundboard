import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/constants/swedish_numbers.dart';

void main() {
  group('Swedish number mapping', () {
    test('check base numbers', () {
      expect(swedishNumberToWords(0), equals('noll'));
      expect(swedishNumberToWords(1), equals('ett'));
      expect(swedishNumberToWords(2), equals('två'));
      expect(swedishNumberToWords(10), equals('tio'));
      expect(swedishNumberToWords(11), equals('elva'));
      expect(swedishNumberToWords(12), equals('tolv'));
      expect(swedishNumberToWords(19), equals('nitton'));
    });

    test('check tens', () {
      expect(swedishNumberToWords(20), equals('tjugo'));
      expect(swedishNumberToWords(30), equals('trettio'));
      expect(swedishNumberToWords(40), equals('fyrtio'));
      expect(swedishNumberToWords(90), equals('nittio'));
      expect(swedishNumberToWords(100), equals('hundra'));
    });

    test('compounded numbers', () {
      expect(swedishNumberToWords(21), equals('tjugoett'));
      expect(swedishNumberToWords(22), equals('tjugotvå'));
      expect(swedishNumberToWords(34), equals('trettiofyra'));
      expect(swedishNumberToWords(48), equals('fyrtioåtta'));
      expect(swedishNumberToWords(63), equals('sextiotre'));
      expect(swedishNumberToWords(98), equals('nittioåtta'));
    });

    test('invalid range throws', () {
      expect(() => swedishNumberToWords(-1), throwsRangeError);
      expect(() => swedishNumberToWords(101), throwsRangeError);
    });
  });
}
