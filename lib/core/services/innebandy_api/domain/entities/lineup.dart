// To parse this JSON data, do
//
//     final match = matchFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

// final lineupSsmlProvider = StateProvider<IbyMatchLineup>((ref) {
//   // Initialize with default values.
//   return IbyMatchLineup(
//     matchId: 0,
//     homeTeamId: 1,
//     homeTeam: 'N/A',
//     homeTeamShortName: '',
//     homeTeamLogotypeUrl: '',
//     awayTeamId: 1,
//     awayTeam: 'N/A',
//     awayTeamShortName: '',
//     awayTeamLogotypeUrl: '',
//     homeTeamPlayers: [],
//     awayTeamPlayers: [],
//     homeTeamTeamPersons: [],
//     awayTeamTeamPersons: [],
//   );
// });
final lineupSsmlProvider = StateProvider<String>((ref) {
  // Initialize with default values.
  return '';
});

final lineupProvider = StateProvider<IbyMatchLineup>((ref) {
  // Initialize with default values.
  return IbyMatchLineup(
    matchId: 0,
    homeTeamId: 1,
    homeTeam: 'N/A',
    homeTeamShortName: '',
    homeTeamLogotypeUrl: '',
    awayTeamId: 1,
    awayTeam: 'N/A',
    awayTeamShortName: '',
    awayTeamLogotypeUrl: '',
    homeTeamPlayers: [],
    awayTeamPlayers: [],
    homeTeamTeamPersons: [],
    awayTeamTeamPersons: [],
  );
});

IbyMatchLineup lineup = IbyMatchLineup(
  awayTeam: 'N/A',
  homeTeam: 'N/A',
  matchId: 0,
  awayTeamId: 1,
  awayTeamLogotypeUrl: '',
  awayTeamPlayers: [],
  awayTeamShortName: '',
  awayTeamTeamPersons: [],
  homeTeamId: 1,
  homeTeamLogotypeUrl: '',
  homeTeamPlayers: [],
  homeTeamShortName: '',
  homeTeamTeamPersons: [],
);
IbyMatchLineup matchFromJson(String str) =>
    IbyMatchLineup.fromJson(json.decode(str));

String matchToJson(IbyMatchLineup data) => json.encode(data.toJson());

class IbyMatchLineup {
  IbyMatchLineup({
    required this.matchId,
    required this.homeTeamId,
    required this.homeTeam,
    required this.homeTeamShortName,
    required this.homeTeamLogotypeUrl,
    required this.awayTeamId,
    required this.awayTeam,
    required this.awayTeamShortName,
    required this.awayTeamLogotypeUrl,
    required this.homeTeamPlayers,
    required this.awayTeamPlayers,
    required this.homeTeamTeamPersons,
    required this.awayTeamTeamPersons,
  });

  int matchId;
  int homeTeamId;
  String homeTeam;
  String homeTeamShortName;
  String homeTeamLogotypeUrl;
  int awayTeamId;
  String awayTeam;
  String awayTeamShortName;
  String awayTeamLogotypeUrl;
  List<TeamPlayer> homeTeamPlayers;
  List<TeamPlayer> awayTeamPlayers;
  List<TeamTeamPerson> homeTeamTeamPersons;
  List<TeamTeamPerson> awayTeamTeamPersons;

  factory IbyMatchLineup.fromJson(Map<String, dynamic> json) => IbyMatchLineup(
    // 2026-09-22: The IBIS public API lineups endpoint now returns null
    // player lists and omits team metadata for matches without a published
    // lineup (e.g. {"HomeTeamPlayers":null,"AwayTeamPlayers":null,...}).
    // All parsing is null-safe to avoid
    // "type 'Null' is not a subtype of type ..." crashes.
    matchId: json["MatchID"] ?? 0,
    homeTeamId: json["HomeTeamID"] ?? 0,
    homeTeam: json["HomeTeam"] ?? '',
    homeTeamShortName: json["HomeTeamShortName"] ?? '',
    homeTeamLogotypeUrl: json["HomeTeamLogotypeUrl"] ?? '',
    awayTeamId: json["AwayTeamID"] ?? 0,
    awayTeam: json["AwayTeam"] ?? '',
    awayTeamShortName: json["AwayTeamShortName"] ?? '',
    awayTeamLogotypeUrl: json["AwayTeamLogotypeUrl"] ?? '',
    homeTeamPlayers:
        (json["HomeTeamPlayers"] as List<dynamic>?)
            ?.map((x) => TeamPlayer.fromJson(x))
            .toList() ??
        [],
    awayTeamPlayers:
        (json["AwayTeamPlayers"] as List<dynamic>?)
            ?.map((x) => TeamPlayer.fromJson(x))
            .toList() ??
        [],
    homeTeamTeamPersons:
        (json["HomeTeamTeamPersons"] as List<dynamic>?)
            ?.map((x) => TeamTeamPerson.fromJson(x))
            .toList() ??
        [],
    awayTeamTeamPersons:
        (json["AwayTeamTeamPersons"] as List<dynamic>?)
            ?.map((x) => TeamTeamPerson.fromJson(x))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "MatchID": matchId,
    "HomeTeamID": homeTeamId,
    "HomeTeam": homeTeam,
    "HomeTeamShortName": homeTeamShortName,
    "HomeTeamLogotypeUrl": homeTeamLogotypeUrl,
    "AwayTeamID": awayTeamId,
    "AwayTeam": awayTeam,
    "AwayTeamShortName": awayTeamShortName,
    "AwayTeamLogotypeUrl": awayTeamLogotypeUrl,
    "HomeTeamPlayers": List<dynamic>.from(
      homeTeamPlayers.map((x) => x.toJson()),
    ),
    "AwayTeamPlayers": List<dynamic>.from(
      awayTeamPlayers.map((x) => x.toJson()),
    ),
    "HomeTeamTeamPersons": List<dynamic>.from(
      homeTeamTeamPersons.map((x) => x.toJson()),
    ),
    "AwayTeamTeamPersons": List<dynamic>.from(
      awayTeamTeamPersons.map((x) => x.toJson()),
    ),
  };
}

class TeamPlayer {
  TeamPlayer({
    this.playerId,
    this.personId,
    this.teamId,
    this.name,
    this.age,
    this.shirtNo,
    this.positionId,
    this.position,
    this.captain,
  });

  int? playerId;
  int? personId;
  int? teamId;
  String? name;
  int? age;
  int? shirtNo;
  int? positionId;
  String? position;
  bool? captain;

  factory TeamPlayer.fromJson(Map<String, dynamic> json) => TeamPlayer(
    playerId: json["PlayerID"],
    personId: json["PersonID"],
    teamId: json["TeamID"],
    name: json["Name"],
    age: json["Age"],
    shirtNo: json["ShirtNo"],
    positionId: json["PositionID"],
    position: json["Position"],
    captain: json["Captain"],
  );

  Map<String, dynamic> toJson() => {
    "PlayerID": playerId,
    "PersonID": personId,
    "TeamID": teamId,
    "Name": name,
    "Age": age,
    "ShirtNo": shirtNo,
    "PositionID": positionId,
    "Position": position,
    "Captain": captain,
  };
}

class TeamTeamPerson {
  TeamTeamPerson({
    this.teamId,
    this.personId,
    this.name,
    this.roleId,
    this.roleName,
  });

  int? teamId;
  int? personId;
  String? name;
  int? roleId;
  String? roleName;

  factory TeamTeamPerson.fromJson(Map<String, dynamic> json) => TeamTeamPerson(
    teamId: json["TeamID"],
    personId: json["PersonID"],
    name: json["Name"],
    roleId: json["RoleID"],
    roleName: json["RoleName"],
  );

  Map<String, dynamic> toJson() => {
    "TeamID": teamId,
    "PersonID": personId,
    "Name": name,
    "RoleID": roleId,
    "RoleName": roleName,
  };
}
