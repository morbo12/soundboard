class Federation {
  static Map<int, String> federations = {
    // 1: "Svenska IBF",
    // 4: "Norrbottens IBF",
    // 5: "Örebro Läns IBF",
    // 6: "Skånes IBF",
    // 7: "Småland Blekinges IBF",
    8: "Stockholms IBF",
    // 9: "Södermanlands IBF",
    // 10: "Upplands IBF",
    // 11: "Värmlands IBF",
    // 12: "Västerbottens IBF",
    // 14: "Västergötlands IBF",
    // 15: "Västmanlands IBF",
    // 16: "Östergötlands IBF",
    // 17: "Västernorrlands IBF",
    // 18: "Dalarnas IBF",
    // 19: "Gotlands IBF",
    // 20: "Gävleborgs IBF",
    // 21: "Västsvenska IBF",
    // 22: "Hallands IBF",
    // 24: "Jämtland/Härjedalens IBF",
    // 44: "Parasport",
  };

  static String getNameById(int id) {
    return federations[id] ?? "Federation not found";
  }

  static int getIdByName(String query) {
    query = query.toLowerCase();
    List<int> matchingIds = [];

    for (var entry in Federation.federations.entries) {
      if (entry.value.toLowerCase().contains(query)) {
        matchingIds.add(entry.key);
      }
    }

    if (matchingIds.length == 1) {
      return matchingIds.first;
    }
    if (matchingIds.length > 1) {
      throw Exception("Error: Multiple federations found for query '$query'");
    } else {
      throw Exception("Error: No federations found for query '$query'");
    }
  }

  static List<String> getFacilitiesList() {
    return federations.values.toList(); // Convert map values to list
  }
}
