import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All translate() keys exist in en.json, sv.json, and cs.json', () async {
    final en = await _loadTranslations('assets/translations/en.json');
    final sv = await _loadTranslations('assets/translations/sv.json');
    final cs = await _loadTranslations('assets/translations/cs.json');

    final keys = await _collectTranslateKeys(Directory('lib'));
    expect(keys, isNotEmpty, reason: 'No translate(\'...\') keys found');

    final missingEn = <String>[];
    final missingSv = <String>[];
    final missingCs = <String>[];

    for (final key in keys) {
      if (!_hasDotKey(en, key)) missingEn.add(key);
      if (!_hasDotKey(sv, key)) missingSv.add(key);
      if (!_hasDotKey(cs, key)) missingCs.add(key);
    }

    expect(
      missingEn,
      isEmpty,
      reason:
          'Missing ${missingEn.length} key(s) in en.json:\n${missingEn.join('\n')}',
    );
    expect(
      missingSv,
      isEmpty,
      reason:
          'Missing ${missingSv.length} key(s) in sv.json:\n${missingSv.join('\n')}',
    );

    expect(
      missingCs,
      isEmpty,
      reason:
          'Missing ${missingCs.length} key(s) in cs.json:\n${missingCs.join('\n')}',
    );
  });
}

Future<Map<String, dynamic>> _loadTranslations(String assetPath) async {
  final jsonString = await rootBundle.loadString(assetPath);
  final decoded = jsonDecode(jsonString);
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Expected a JSON object at $assetPath');
  }
  return decoded;
}

Future<Set<String>> _collectTranslateKeys(Directory root) async {
  final keys = <String>{};
  final translateRegex = RegExp(
    "translate\\(\\s*(['\\\"])([^'\\\"]+)\\1\\s*\\)",
    multiLine: true,
  );

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart')) continue;
    if (entity.path.endsWith('.freezed.dart')) continue;

    final source = await entity.readAsString();
    for (final match in translateRegex.allMatches(source)) {
      final key = match.group(2);
      if (key != null && key.isNotEmpty) {
        keys.add(key);
      }
    }
  }

  return keys;
}

bool _hasDotKey(Map<String, dynamic> root, String dottedKey) {
  dynamic current = root;
  for (final part in dottedKey.split('.')) {
    if (current is! Map<String, dynamic>) return false;
    if (!current.containsKey(part)) return false;
    current = current[part];
  }
  return true;
}
