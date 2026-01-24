import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/ssml_template_service.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';

void main() {
  group('SsmlTemplateService Swedish Numbers', () {
    test('renders lineup with Swedish number words for shirt numbers', () {
      final players = [
        TeamPlayer(name: 'Erik Johansson', shirtNo: 23, position: 'Forward'),
        TeamPlayer(name: 'Anna Svensson', shirtNo: 7, position: 'Defense'),
        TeamPlayer(name: 'Lars Andersson', shirtNo: 98, position: 'Midfield'),
        TeamPlayer(name: 'Kalle Målvakt', shirtNo: 1, position: 'Målvakt'),
      ];

      final result = SsmlTemplateService.renderLineup(
        teamName: 'Test Team',
        players: players,
        teamPersons: [],
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should contain Swedish words instead of digits
      expect(result, contains('tjugotre')); // 23
      expect(result, contains('sju')); // 7
      expect(result, contains('nittioåtta')); // 98

      // Should not contain digit representations for non-goalkeeper players
      expect(result, isNot(contains('Nummer 23')));
      expect(result, isNot(contains('Nummer 98')));

      // Check structure
      expect(result, contains('<speak'));
      expect(result, contains('</speak>'));
    });

    test('handles shirt numbers out of range gracefully', () {
      final players = [
        TeamPlayer(
          name: 'Test Player',
          shirtNo: 150, // Out of 0-100 range
          position: 'Forward',
        ),
      ];

      // Should not throw, should fall back to digit
      expect(
        () => SsmlTemplateService.renderLineup(
          teamName: 'Test Team',
          players: players,
          teamPersons: [],
          voiceName: 'sv-SE-SofieNeural',
        ),
        returnsNormally,
      );
    });
  });
}
