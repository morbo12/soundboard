// IntermediateResult event = IntermediateResult(
//     goalsAwayTeam: 0, goalsHomeTeam: 0, matchID: 0, period: 0);

// class IntermediateResult {
//   final int matchID;
//   final int period;
//   final int goalsHomeTeam;
//   final int goalsAwayTeam;

//   const IntermediateResult({
//     required this.matchID,
//     required this.period,
//     required this.goalsHomeTeam,
//     required this.goalsAwayTeam,
//   });

//   // Factory constructor to create an IntermediateResult from JSON
//   factory IntermediateResult.fromJson(Map<String, dynamic> json) =>
//       IntermediateResult(
//         matchID: json["MatchID"] as int,
//         period: json["Period"] as int,
//         goalsHomeTeam: json["GoalsHomeTeam"] as int,
//         goalsAwayTeam: json["GoalsAwayTeam"] as int,
//       );

//   // Convert IntermediateResult to JSON
//   Map<String, dynamic> toJson() => {
//         'MatchID': matchID,
//         'Period': period,
//         'GoalsHomeTeam': goalsHomeTeam,
//         'GoalsAwayTeam': goalsAwayTeam,
//       };

//   // Copy with method for creating a new instance with some modified fields
//   IntermediateResult copyWith({
//     int? matchID,
//     int? period,
//     int? goalsHomeTeam,
//     int? goalsAwayTeam,
//   }) {
//     return IntermediateResult(
//       matchID: matchID ?? this.matchID,
//       period: period ?? this.period,
//       goalsHomeTeam: goalsHomeTeam ?? this.goalsHomeTeam,
//       goalsAwayTeam: goalsAwayTeam ?? this.goalsAwayTeam,
//     );
//   }

//   @override
//   String toString() {
//     return 'IntermediateResult(matchID: $matchID, period: $period, '
//         'goalsHomeTeam: $goalsHomeTeam, goalsAwayTeam: $goalsAwayTeam)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is IntermediateResult &&
//         other.matchID == matchID &&
//         other.period == period;
//   }

//   @override
//   int get hashCode => Object.hash(matchID, period);
// }

// // Helper class to parse a list of IntermediateResults
// class IntermediateResults {
//   final List<IntermediateResult> results;

//   const IntermediateResults({
//     required this.results,
//   });

//   // Factory constructor to create IntermediateResults from JSON
//   factory IntermediateResults.fromJson(List<dynamic> json) {
//     return IntermediateResults(
//       results: json
//           .map((x) => IntermediateResult.fromJson(x as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   // Convert IntermediateResults to JSON
//   List<Map<String, dynamic>> toJson() {
//     return results.map((x) => x.toJson()).toList();
//   }
// }
