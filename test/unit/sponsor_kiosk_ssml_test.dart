import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/ssml_template_service.dart';
import 'package:soundboard/core/properties.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('SsmlTemplateService Sponsor & Kiosk Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      await SettingsBox().init();
    });

    tearDown(() {
      // Reset settings after each test
      final settings = SettingsBox();
      settings.sponsorEnabled = false;
      settings.mainSponsor = '';
      settings.otherSponsors = [];
      settings.kioskEnabled = false;
    });

    test('renders welcome message without sponsors or kiosk', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = false;
      settings.kioskEnabled = false;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should contain basic welcome message
      expect(result, contains('Välkomna till Händevisehallen'));
      expect(result, contains('IFK Haninge hälsar motståndarna'));
      expect(result, contains('Järfälla IBK'));

      // Should NOT contain sponsor or kiosk messages
      expect(result, isNot(contains('huvudsponsor')));
      expect(result, isNot(contains('Vi vill också tacka')));
      expect(result, isNot(contains('Kiosken är öppen')));
    });

    test('renders welcome message with main sponsor only', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = true;
      settings.mainSponsor = 'Haninge Kommun';
      settings.otherSponsors = [];
      settings.kioskEnabled = false;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should contain main sponsor message
      expect(result, contains('Välkomna till Händevisehallen'));
      expect(
        result,
        contains(
          'IFK Haninge, tillsammans med vår huvudsponsor Haninge Kommun',
        ),
      );
      expect(result, contains('hälsar motståndarna'));

      // Should NOT contain other sponsor message
      expect(result, isNot(contains('Vi vill också tacka')));
    });

    test('renders welcome message with main sponsor and one other sponsor', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = true;
      settings.mainSponsor = 'Haninge Kommun';
      settings.otherSponsors = ['ICA Maxi'];
      settings.kioskEnabled = false;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should contain main sponsor
      expect(result, contains('huvudsponsor Haninge Kommun'));

      // Should contain other sponsor (single sponsor, no "och")
      expect(result, contains('Vi vill också tacka ICA Maxi'));
    });

    test('renders welcome message with main sponsor and two other sponsors', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = true;
      settings.mainSponsor = 'Haninge Kommun';
      settings.otherSponsors = ['ICA Maxi', 'Sportson'];
      settings.kioskEnabled = false;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should contain main sponsor
      expect(result, contains('huvudsponsor Haninge Kommun'));

      // Should contain other sponsors with "och" between them
      expect(result, contains('Vi vill också tacka ICA Maxi och Sportson'));
    });

    test(
      'renders welcome message with main sponsor and three other sponsors',
      () {
        final settings = SettingsBox();
        settings.sponsorEnabled = true;
        settings.mainSponsor = 'Haninge Kommun';
        settings.otherSponsors = ['ICA Maxi', 'Sportson', 'Coop'];
        settings.kioskEnabled = false;

        final result = SsmlTemplateService.renderWelcome(
          homeTeam: 'IFK Haninge',
          awayTeam: 'Järfälla IBK',
          venue: 'Händevisehallen',
          voiceName: 'sv-SE-SofieNeural',
        );

        // Should contain main sponsor
        expect(result, contains('huvudsponsor Haninge Kommun'));

        // Should contain other sponsors with commas and final "och"
        expect(
          result,
          contains('Vi vill också tacka ICA Maxi, Sportson, och Coop'),
        );
      },
    );

    test('renders welcome message with kiosk announcement only', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = false;
      settings.kioskEnabled = true;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should contain kiosk message
      expect(result, contains('Kiosken är öppen'));
      expect(result, contains('välkommen att besöka oss under pausen'));

      // Should NOT contain sponsor message
      expect(result, isNot(contains('huvudsponsor')));
    });

    test('renders welcome message with sponsors and kiosk', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = true;
      settings.mainSponsor = 'Haninge Kommun';
      settings.otherSponsors = ['ICA Maxi', 'Sportson'];
      settings.kioskEnabled = true;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should contain all elements
      expect(result, contains('Välkomna till Händevisehallen'));
      expect(result, contains('huvudsponsor Haninge Kommun'));
      expect(result, contains('Vi vill också tacka ICA Maxi och Sportson'));
      expect(result, contains('Kiosken är öppen'));

      // Should have proper SSML structure
      expect(result, contains('<speak'));
      expect(result, contains('</speak>'));
      expect(result, contains('<voice name="sv-SE-SofieNeural">'));
    });

    test('handles empty main sponsor when sponsor is enabled', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = true;
      settings.mainSponsor = ''; // Empty
      settings.otherSponsors = ['ICA Maxi'];
      settings.kioskEnabled = false;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Should NOT show main sponsor section
      expect(result, isNot(contains('huvudsponsor')));

      // Should show basic welcome
      expect(result, contains('IFK Haninge hälsar motståndarna'));

      // Should show other sponsors
      expect(result, contains('Vi vill också tacka ICA Maxi'));
    });

    test('validates SSML structure', () {
      final settings = SettingsBox();
      settings.sponsorEnabled = true;
      settings.mainSponsor = 'Test Sponsor';
      settings.kioskEnabled = true;

      final result = SsmlTemplateService.renderWelcome(
        homeTeam: 'IFK Haninge',
        awayTeam: 'Järfälla IBK',
        venue: 'Händevisehallen',
        voiceName: 'sv-SE-SofieNeural',
      );

      // Verify SSML structure
      expect(result, startsWith('<speak'));
      expect(result, endsWith('</speak>'));
      expect(result, contains('<voice name="sv-SE-SofieNeural">'));
      expect(result, contains('</voice>'));

      // Check for break tags
      expect(result, contains('<break time='));
    });
  });
}
