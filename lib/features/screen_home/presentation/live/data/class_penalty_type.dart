class PenaltyType {
  final String code;
  final String name;
  final String penaltyTime;

  PenaltyType({
    required this.code,
    required this.name,
    required this.penaltyTime,
  });

  factory PenaltyType.fromJson(Map<String, dynamic> json) {
    return PenaltyType(
      code: json['Code'],
      name: json['Name'],
      penaltyTime: extractPenaltyTime(json['Name']),
    );
  }

  static String extractPenaltyTime(String penaltyName) {
    RegExp timeRegExp = RegExp(r'\b\d+(\+\d+)?\s*min\b');
    Match? match = timeRegExp.firstMatch(penaltyName);

    return match?.group(0) ?? "Unknown";
  }

  static const String twoMinutes = "2 minuter";
  static const String fiveMinutes = "5 minuter";
  static const String tenMinutes = "10 minuter";
  // Add more penalty times as needed for specific cases
}

class PenaltyTypes {
  static List<PenaltyType> penaltyTypes = [
    PenaltyType(
        code: "225",
        name: "Ej avlägsnat avslagna klubbdelar",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "209", name: "Fasthållning", penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "221",
        name: "Felaktig utrustning",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "211",
        name: "Felaktigt avstånd",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "220",
        name: "Felaktigt beträdande av spelplan",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "215",
        name: "Felaktigt byte",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "216",
        name: "För många spelare på plan",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "218",
        name: "Fördröjande av spelet",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "213", name: "Hands", penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "208", name: "Hårt spel", penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "206", name: "Hög klubba", penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "205", name: "Hög spark", penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "212",
        name: "Liggande spel",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "203",
        name: "Lyftning av klubba",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "202",
        name: "Låsning av klubba",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "222",
        name: "Mätning av klubba",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "210", name: "Obstruktion", penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "301", name: "Osportsligt uppträdande", penaltyTime: "2+10 min"),
    PenaltyType(
        code: "204",
        name: "Otillåten spark",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "207",
        name: "Otillåten trängning",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "219",
        name: "Protest mot domslut",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(code: "201", name: "Slag", penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "224",
        name: "Spel utan klubba",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "217",
        name: "Upprepade förseelser",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(code: "404", name: "Hårt spel", penaltyTime: "2+2 min"),
    PenaltyType(code: "402", name: "Hakning", penaltyTime: "2+2 min"),
    PenaltyType(
        code: "401",
        name: "Vårdslöst spel med klubban",
        penaltyTime: "2+2 min"),
    PenaltyType(
        code: "403", name: "Kasta klubban mot bollen", penaltyTime: "2+2 min"),
    PenaltyType(
        code: "611",
        name: "Tekniskt matchstraff, Ej godkänd klubba/ansiktsskydd",
        penaltyTime: ""),
    PenaltyType(
        code: "612",
        name: "Tekniskt matchstraff, Ej upptagen i matchprotokollet",
        penaltyTime: ""),
    PenaltyType(
        code: "631", name: "Grovt matchstraff, Slagsmål", penaltyTime: ""),
    PenaltyType(
        code: "632",
        name: "Grovt matchstraff, Brutal förseelse",
        penaltyTime: ""),
    PenaltyType(
        code: "633", name: "Grovt matchstraff, Missfirmelse", penaltyTime: ""),
    PenaltyType(
        code: "634",
        name: "Grovt matchstraff, Hotfullt uppträdande",
        penaltyTime: ""),
    PenaltyType(
        code: "223",
        name: "Felaktig klädsel",
        penaltyTime: PenaltyType.twoMinutes),
    PenaltyType(
        code: "621",
        name:
            "Lindrigt matchstraff, Fortsatt eller upprepat osportsligt uppträdande",
        penaltyTime: ""),
    PenaltyType(
        code: "622",
        name: "Lindrigt matchstraff, Slå sönder klubban eller annan utrustning",
        penaltyTime: ""),
    PenaltyType(
        code: "623",
        name: "Lindrigt matchstraff, Våldsamt fysiskt spel",
        penaltyTime: ""),
    PenaltyType(
        code: "624", name: "Lindrigt matchstraff, Handgemäng", penaltyTime: ""),
    PenaltyType(
        code: "625",
        name: "Lindrigt matchstraff, Upprepade större lagstraff",
        penaltyTime: ""),
    PenaltyType(
        code: "626",
        name: "Lindrigt matchstraff, Åtgärdat utrustning vid begärd kontroll",
        penaltyTime: ""),
    PenaltyType(
        code: "627",
        name: "Lindrigt matchstraff, Sabotage av spelet",
        penaltyTime: ""),
    PenaltyType(
        code: "628",
        name: "Lindrigt matchstraff, Spel med trasig eller förstärkt klubba",
        penaltyTime: ""),
    PenaltyType(
        code: "629",
        name:
            "Lindrigt matchstraff, Delta i konfrontation från byteszon/utvisningsbänk",
        penaltyTime: ""),
  ];

  static Map<String, String> getPenaltyInfo(String penaltyCode) {
    final penaltyType = penaltyTypes.firstWhere(
      (element) => element.code == penaltyCode,
      orElse: () => PenaltyType(
        code: "000",
        name: "Unknown",
        penaltyTime: "Unknown",
      ),
    );
    return {'name': penaltyType.name, 'time': penaltyType.penaltyTime};
  }
}
