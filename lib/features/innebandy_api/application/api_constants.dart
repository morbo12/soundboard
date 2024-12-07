class APIConstants {
  static const String baseUrl = 'https://api.innebandy.se/';

  static const String startKit = 'StatsAppApi/api/startkit';
  static const String season = 'v2/api/seasons';
  // static const String getMatchesInVenue = 'v2/api/venues/{venueId}/matches';
  static const String matchLineup = 'v2/api/matches/{matchId}/lineups';
  static const String venueMatches =
      '/v2/api/seasons/{seasonId}/venues/{venueId}/matches';
  static const String match = "v2/api/matches/{matchId}";
}
