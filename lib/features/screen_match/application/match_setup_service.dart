import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/competition_service.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/match_service.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/season_service.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition_type.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Service responsible for fetching and managing match data for the match setup screen.
///
/// This service handles the coordination between different API services to fetch
/// matches based on selected date and venue. It also provides error handling
/// and logging for the match fetching process.
class MatchSetupService {
  /// Reference to the Riverpod container for accessing providers.
  final Ref ref;

  /// Logger instance for tracking service operations and errors.
  final Logger logger = const Logger('MatchSetupService');

  /// Creates a new instance of [MatchSetupService].
  ///
  /// [ref] is required to access other providers in the application.
  MatchSetupService(this.ref);

  /// Fetches matches for a specific date and venue.
  ///
  /// This method:
  /// 1. Gets the current season ID
  /// 2. Fetches matches for the specified date and venue
  /// 3. Validates the results
  /// 4. Handles errors appropriately
  ///
  /// Throws an [Exception] if:
  /// - No matches are found for the given criteria
  /// - There's an error during the API call
  ///
  /// Returns a [List<IbyMatch>] containing the matches found.
  Future<List<IbyMatch>> getMatches({
    required DateTime date,
    required int venueId,
  }) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final seasonService = SeasonService(apiClient);
      final matchService = MatchService(apiClient);

      // Get current season ID
      final seasonId = await seasonService.getCurrentSeason();
      logger.d("SeasonID: $seasonId");
      logger.d(
        "date: ${DateFormat('yyyy-MM-dd').format(date)} | seasonId: $seasonId | venueId: $venueId",
      );

      // Fetch matches for the given criteria
      final matches = await matchService.getMatchesInVenue(
        date: DateFormat('yyyy-MM-dd').format(date),
        seasonId: seasonId,
        venueId: venueId,
      );

      // Validate that matches were found
      if (matches.isEmpty) {
        throw Exception(
          'Inga matcher hittades för det valda datumet och anläggningen',
        );
      }

      return matches;
    } on Exception catch (e) {
      logger.e('Error fetching matches: $e');
      rethrow;
    }
  }

  /// Fetches competitions or tournaments for a given federation.
  Future<List<Competition>> getCompetitions({
    required int federationId,
    required CompetitionType type,
  }) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final seasonService = SeasonService(apiClient);
      final competitionService = CompetitionService(apiClient);

      final seasonId = await seasonService.getCurrentSeason();
      logger.d(
        "Fetching ${type.displayName} for seasonId: $seasonId, federationId: $federationId",
      );

      final competitions = await competitionService.getCompetitions(
        seasonId: seasonId,
        federationId: federationId,
        type: type,
      );

      if (competitions.isEmpty) {
        throw Exception(
          'Inga ${type.displayName.toLowerCase()} hittades för det valda förbundet',
        );
      }

      return competitions;
    } on Exception catch (e) {
      logger.e('Error fetching competitions: $e');
      rethrow;
    }
  }

  /// Fetches matches for a specific competition.
  /// For tournaments, use getMatchesFromTournament instead.
  Future<List<IbyMatch>> getMatchesFromCompetition({
    required int competitionId,
    DateTime? date,
  }) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final matchService = MatchService(apiClient);

      logger.d(
        "Fetching matches for competitionId: $competitionId${date != null ? ', date: ${DateFormat('yyyy-MM-dd').format(date)}' : ''}",
      );

      final matches = await matchService.getMatchesInCompetition(
        competitionId: competitionId,
        date: date != null ? DateFormat('yyyy-MM-dd').format(date) : null,
      );

      if (matches.isEmpty) {
        throw Exception(
          'Inga matcher hittades för den valda tävlingen${date != null ? ' och datumet' : ''}',
        );
      }

      return matches;
    } on Exception catch (e) {
      logger.e('Error fetching matches from competition: $e');
      rethrow;
    }
  }

  /// Fetches all matches for a specific tournament.
  /// Tournaments use a different API that returns competition details with all matches.
  /// No date filtering is applied - all tournament matches are returned.
  Future<List<IbyMatch>> getMatchesFromTournament({
    required int competitionCategoryId,
  }) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final seasonService = SeasonService(apiClient);
      final competitionService = CompetitionService(apiClient);

      final seasonId = await seasonService.getCurrentSeason();

      logger.d(
        "Fetching all tournament matches for competitionCategoryId: $competitionCategoryId",
      );

      final competitionsWithMatches = await competitionService
          .getCompetitionCategoryWithMatches(
            seasonId: seasonId,
            competitionCategoryId: competitionCategoryId,
          );

      if (competitionsWithMatches.isEmpty) {
        throw Exception('Ingen tävlingsinformation hittades');
      }

      // Get all matches from all competitions in the category
      List<IbyMatch> allMatches = [];
      for (var comp in competitionsWithMatches) {
        allMatches.addAll(comp.matches);
      }

      if (allMatches.isEmpty) {
        throw Exception('Inga matcher hittades för den valda turneringen');
      }

      // Sort matches by date
      allMatches.sort(
        (a, b) => DateTime.parse(
          a.matchDateTime,
        ).compareTo(DateTime.parse(b.matchDateTime)),
      );

      return allMatches;
    } on Exception catch (e) {
      logger.e('Error fetching matches from tournament: $e');
      rethrow;
    }
  }
}
