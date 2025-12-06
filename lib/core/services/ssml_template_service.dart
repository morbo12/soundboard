import 'package:mustache_template/mustache_template.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/constants/swedish_numbers.dart';

/// Service for rendering SSML templates with data
class SsmlTemplateService {
  static const Logger _logger = Logger('SsmlTemplateService');

  /// Wraps content with SSML speak and voice tags
  static String _wrapWithSsml(String content, String voiceName) {
    return '''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
$content
</voice>
</speak>''';
  }

  /// Get SSML tag helper variables for templates
  static Map<String, String> _getSsmlHelpers() {
    return {
      'nameOpen': '<say-as interpret-as="name">',
      'nameClose': '</say-as>',
      'emphasisStrongOpen': '<emphasis level="strong">',
      'emphasisStrongClose': '</emphasis>',
      'emphasisModerateOpen': '<emphasis level="moderate">',
      'emphasisModerateClose': '</emphasis>',
      'prosodySlowOpen': '<prosody rate="slow">',
      'prosodySlowClose': '</prosody>',
      'prosodyFastOpen': '<prosody rate="fast">',
      'prosodyFastClose': '</prosody>',
      'prosodyLoudOpen': '<prosody volume="loud">',
      'prosodyLoudClose': '</prosody>',
      'prosodySoftOpen': '<prosody volume="soft">',
      'prosodySoftClose': '</prosody>',
    };
  }

  /// Process dynamic break tags like {{break:1235}} into <break time="1235ms"/>
  static String _processDynamicBreaks(String content) {
    final regex = RegExp(r'\{\{break:(\d+)\}\}');
    return content.replaceAllMapped(regex, (match) {
      final milliseconds = match.group(1);
      return '<break time="${milliseconds}ms"/>';
    });
  }

  /// Renders the welcome message template
  static String renderWelcome({
    required String homeTeam,
    required String awayTeam,
    required String venue,
    required String voiceName,
  }) {
    try {
      final template = Template(
        SettingsBox().ssmlWelcomeTemplate,
        lenient: true,
        htmlEscapeValues: false,
      );

      final data = {
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'venue': venue,
        ..._getSsmlHelpers(),
      };

      var content = template.renderString(data);
      content = _processDynamicBreaks(content);
      return _wrapWithSsml(content, voiceName);
    } catch (e) {
      _logger.e('Error rendering welcome template: $e');
      return _fallbackWelcome(homeTeam, awayTeam, venue, voiceName);
    }
  }

  /// Renders a team lineup template
  static String renderLineup({
    required String teamName,
    required List<TeamPlayer> players,
    required List<TeamTeamPerson> teamPersons,
    required String voiceName,
  }) {
    try {
      final template = Template(
        SettingsBox().ssmlLineupTemplate,
        lenient: true,
        htmlEscapeValues: false,
      );

      // Prepare players data with flags for conditionals
      final playersData = players.map((player) {
        final isGoalkeeper = player.position == "Målvakt";
        final hasShirtNo = player.shirtNo != null;

        // Convert shirt number to Swedish words
        String? shirtNoText;
        if (hasShirtNo && player.shirtNo != null) {
          try {
            shirtNoText = swedishNumberToWords(player.shirtNo!);
          } catch (e) {
            // If number is out of range, fall back to digit
            shirtNoText = player.shirtNo.toString();
          }
        }

        return {
          'name': player.name ?? 'Unknown',
          'shirtNo': shirtNoText,
          'isGoalkeeper': isGoalkeeper,
          'hasShirtNo': hasShirtNo && !isGoalkeeper,
        };
      }).toList();

      // Prepare team persons data
      final teamPersonsData = teamPersons.map((person) {
        return {'name': person.name ?? 'Unknown'};
      }).toList();

      final data = {
        'teamName': teamName,
        'players': playersData,
        'teamPersons': teamPersonsData,
        ..._getSsmlHelpers(),
      };

      var content = template.renderString(data);
      content = _processDynamicBreaks(content);
      return _wrapWithSsml(content, voiceName);
    } catch (e) {
      _logger.e('Error rendering lineup template: $e');
      return _fallbackLineup(teamName, players, teamPersons, voiceName);
    }
  }

  /// Renders the referee announcement template
  static String renderReferee({
    required String referee1,
    required String referee2,
    required String voiceName,
  }) {
    try {
      final template = Template(
        SettingsBox().ssmlRefereeTemplate,
        lenient: true,
        htmlEscapeValues: false,
      );

      final data = {
        'referee1': referee1,
        'referee2': referee2,
        ..._getSsmlHelpers(),
      };

      var content = template.renderString(data);
      content = _processDynamicBreaks(content);
      return _wrapWithSsml(content, voiceName);
    } catch (e) {
      _logger.e('Error rendering referee template: $e');
      return _fallbackReferee(referee1, referee2, voiceName);
    }
  }

  // Fallback methods in case template rendering fails
  static String _fallbackWelcome(
    String homeTeam,
    String awayTeam,
    String venue,
    String voiceName,
  ) {
    return '''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Välkomna till $venue!
<break time="1000ms"/>
$homeTeam hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan $homeTeam och $awayTeam
<break time="1000ms"/>
</voice>
</speak>''';
  }

  static String _fallbackLineup(
    String teamName,
    List<TeamPlayer> players,
    List<TeamTeamPerson> teamPersons,
    String voiceName,
  ) {
    String ssml =
        "<speak version=\"1.0\" xmlns=\"http://www.w3.org/2001/10/synthesis\" xmlns:mstts=\"https://www.w3.org/2001/mstts\" xml:lang=\"sv-SE\">\n<voice name=\"$voiceName\">\n$teamName ställer upp med följande spelare<break time=\"750ms\"/>\n";

    String goalie =
        "Dagens målvakt är inte inlagd i truppen<break time=\"750ms\"/>\n";
    for (TeamPlayer player in players) {
      if (player.position == "Målvakt") {
        goalie =
            "Dagens målvakt är <say-as interpret-as=\"name\">${player.name}</say-as><break time=\"500ms\"/>\n";
      } else {
        if (player.shirtNo == null) {
          ssml +=
              "<say-as interpret-as=\"name\">${player.name}</say-as><break time=\"750ms\"/>\n";
        } else {
          // Convert shirt number to Swedish words
          String shirtNoText;
          try {
            shirtNoText = swedishNumberToWords(player.shirtNo!);
          } catch (e) {
            // If number is out of range, fall back to digit
            shirtNoText = player.shirtNo.toString();
          }
          ssml +=
              "Nummer $shirtNoText, <say-as interpret-as=\"name\">${player.name}</say-as><break time=\"750ms\"/>\n";
        }
      }
    }

    ssml += goalie;
    ssml += "<break time=\"500ms\"/>\n";
    ssml += "Ledare för $teamName är<break time=\"750ms\"/>\n";

    for (TeamTeamPerson teamPerson in teamPersons) {
      ssml +=
          "<say-as interpret-as=\"name\">${teamPerson.name}</say-as><break time=\"1000ms\"/>\n";
    }

    ssml += "<break time=\"1000ms\"/>\n</voice>\n</speak>";
    return ssml;
  }

  static String _fallbackReferee(
    String referee1,
    String referee2,
    String voiceName,
  ) {
    return '''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Domare i denna match är,,
$referee1 och $referee2
</voice>
</speak>''';
  }
}
