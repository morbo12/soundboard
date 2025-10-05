enum CompetitionType {
  competition,
  tournament;

  String get displayName {
    switch (this) {
      case CompetitionType.competition:
        return 'Tävling';
      case CompetitionType.tournament:
        return 'Turnering';
    }
  }
}
