// Generated Swedish numbers map 0..100

Map<int, String> swedishNumbers = _buildSwedishNumbersMap();

const Map<int, String> _baseNumbers = {
  0: 'noll',
  1: 'ett',
  2: 'två',
  3: 'tre',
  4: 'fyra',
  5: 'fem',
  6: 'sex',
  7: 'sju',
  8: 'åtta',
  9: 'nio',
  10: 'tio',
  11: 'elva',
  12: 'tolv',
  13: 'tretton',
  14: 'fjorton',
  15: 'femton',
  16: 'sexton',
  17: 'sjutton',
  18: 'arton',
  19: 'nitton',
};

const Map<int, String> _tens = {
  20: 'tjugo',
  30: 'trettio',
  40: 'fyrtio',
  50: 'femtio',
  60: 'sextio',
  70: 'sjuttio',
  80: 'åttio',
  90: 'nittio',
  100: 'hundra',
};

Map<int, String> _buildSwedishNumbersMap() {
  final map = <int, String>{};

  // add base numbers 0..19
  map.addAll(_baseNumbers);

  // Add exact multiples of ten
  for (final kv in _tens.entries) {
    map[kv.key] = kv.value;
  }

  // Build 21..99 by compounding tens and units
  for (int n = 21; n < 100; n++) {
    if (map.containsKey(n)) continue; // skip tens already added

    final int tensPart = (n ~/ 10) * 10;
    final int onesPart = n % 10;
    final tensWord = _tens[tensPart] ?? '';
    final onesWord = _baseNumbers[onesPart] ?? '';
    map[n] = '$tensWord$onesWord';
  }

  // 100
  map[100] = _tens[100]!;

  return Map.unmodifiable(map);
}

String swedishNumberToWords(int number) {
  if (number < 0 || number > 100) throw RangeError.range(number, 0, 100);
  return swedishNumbers[number]!;
}
