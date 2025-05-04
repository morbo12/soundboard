import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:soundboard/features/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/features/innebandy_api/data/datasources/remote/match_service.dart';
import 'package:soundboard/features/innebandy_api/data/datasources/remote/season_service.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/utils/logger.dart';

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
}
