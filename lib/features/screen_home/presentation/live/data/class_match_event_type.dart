class MatchEventType {
  final int matchEventTypeID;
  final String name;
  static const int mal = 1;
  static const int utvisning = 2;
  static const int timeoutHemma = 3;
  static const int timeoutBorta = 4;
  static const int straffmal = 5;
  static const int missadStraff = 6;
  static const int periodstart = 8;
  static const int periodslut = 9;
  static const int malvaktIn = 10;
  static const int malvaktUt = 11;
  static const int malTomBur = 12;
  static const int lineup = 9999;

  MatchEventType({
    required this.matchEventTypeID,
    required this.name,
  });

  factory MatchEventType.fromJson(Map<String, dynamic> json) {
    return MatchEventType(
      matchEventTypeID: json['MatchEventTypeID'],
      name: json['Name'],
    );
  }
}

class MatchEventTypes {
  static List<MatchEventType> eventTypes = [
    MatchEventType(matchEventTypeID: 1, name: "Mål"),
    MatchEventType(matchEventTypeID: 2, name: "Utvisning"),
    MatchEventType(matchEventTypeID: 3, name: "Time Out - Hemma"),
    MatchEventType(matchEventTypeID: 4, name: "Time Out - Borta"),
    MatchEventType(matchEventTypeID: 5, name: "Straffmål"),
    MatchEventType(matchEventTypeID: 6, name: "Missad straff"),
    MatchEventType(matchEventTypeID: 10, name: "Målvakt - In"),
    MatchEventType(matchEventTypeID: 11, name: "Målvakt - Ut"),
    MatchEventType(matchEventTypeID: 12, name: "Mål i tom bur"),
  ];

  static String getEventName(int eventTypeID) {
    final eventType = eventTypes.firstWhere(
      (element) => element.matchEventTypeID == eventTypeID,
      orElse: () => MatchEventType(matchEventTypeID: 0, name: "Unknown"),
    );
    return eventType.name;
  }
}
