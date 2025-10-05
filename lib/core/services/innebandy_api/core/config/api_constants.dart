class APIConstants {
  static const String baseUrl = 'https://api.innebandy.se/';

  static const String startKit = 'StatsAppApi/api/startkit';
  static const String apiRoot = 'v2/api';
  static const String season = '${apiRoot}/seasons';
  // static const String getMatchesInVenue = '${apiRoot}/venues/{venueId}/matches';
  static const String matchLineup = '${apiRoot}/matches/{matchId}/lineups';
  static const String venueMatches =
      '/${apiRoot}/seasons/{seasonId}/venues/{venueId}/matches';
  static const String match = "${apiRoot}/matches/{matchId}";
  static const String standings =
      "${apiRoot}/competitions/{competitionId}/standings";
  static const String playerStatistics =
      "${apiRoot}/competitions/{competitionId}/playerstatistics";
  static const String competitions =
      '${apiRoot}/seasons/{seasonId}/federations/{federationId}/competitions';
  static const String tournaments =
      '${apiRoot}/seasons/{seasonId}/federations/{federationId}/tournaments';
  static const String competitionMatches =
      '${apiRoot}/competitions/{competitionId}/matches';
  static const String competitionCategoryWithMatches =
      '${apiRoot}/seasons/{seasonId}/competitioncategories/{competitionCategoryId}/competitionswithmatchesandstandings';
}
