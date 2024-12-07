class ArenasInStockholm {
  static Map<int, String> facilities = {
    1237: "Arena Satelliten",
    4205: "Bagartorpshallen",
    1239: "Bandhagshallen",
    4246: "Bas Barkarby",
    1240: "Björkeby Sporthall",
    1247: "Bodals Bollhall",
    1265: "Botkyrkahallen",
    1250: "Bro Sporthall",
    2136: "Brotorpshallen",
    4443: "Charlottendalshallen",
    1252: "Danderyds Gymnasium",
    1350: "Djurö Sporthall",
    1263: "Ekhammarhallen",
    1360: "Ekillahallen",
    1325: "Engelbrektshallen",
    1283: "Eriksdalshallen",
    1309: "Erikslundshallen",
    1256: "Farstahallen 1",
    1258: "Farstahallen 3",
    1301: "Fisksätra Sporthall",
    1340: "Flemingsbergshallen",
    3241: "Flemingshallen",
    3603: "Glömstahallen",
    3250: "Grimstahallen",
    2924: "Grindtorpshallen",
    1314: "Gröndalshallen",
    1286: "Gubbängshallen",
    1336: "Gärdeshallen",
    1249: "Hackstahallen",
    1356: "Hagnäshallen",
    1319: "Hallonbergshallen",
    3109: "Herresta Sporthall",
    3613: "Hjorthagshallen",
    1293: "Hässelbyhallen",
    1253: "Högdalshallen",
    1254: "Ingarö Sporthall",
    1248: "Jakobsbergs Sporthall",
    2600: "Jordbromalms Sporthall",
    2144: "Järla Sporthall",
    3611: "K-Rauta Arena",
    1270: "Kallhäll Sporthall",
    2507: "Kolstahallen",
    3227: "Kvarnbergshallen",
    1313: "Kvarnängens Sporthall",
    3995: "Kungshallen",
    3608: "Kämpetorpshallen 1",
    3609: "Kämpetorpshallen 2",
    1288: "Liljeholmshallarna",
    3455: "Lyckeby Sporthall",
    1320: "Löthallen",
    1352: "Malmsjö Sporthall",
    1302: "Myrsjöskolan",
    3080: "Mälaröhallen",
    1262: "Mörbyhallen",
    3580: "Nya Edsbergshallen",
    1264: "Ormingehallen",
    1317: "Prästängshallen",
    1279: "Silverdalshallen",
    1292: "Sjöstadshallen",
    4253: "Skanskvarnshallen",
    1338: "Skarpnäckshallen",
    1328: "Skarpängsskolan A",
    1329: "Skarpängsskolan B",
    1315: "Skogsängshallen",
    1295: "Skogåshallen",
    1255: "Skärholmshallen",
    1291: "Sköndalshallen",
    1268: "Smedsgärdshallen",
    1278: "Sollentuna Sim och Sporthall",
    1323: "Solnahallen",
    3584: "S:T Erikshallen",
    1344: "Stavsborgshallen",
    1312: "Stenhamra Bollhall",
    1362: "Stora Mossen 1",
    1363: "Stora Mossen 2",
    1275: "Storvretens Sporthall",
    1281: "Strandhallen",
    3248: "Stuvstahallen",
    2927: "Sätrahallen",
    1305: "Söderbymalmsskolan",
    1261: "Tallbackaskolan",
    1260: "Tappströms Bollhall",
    4445: "Tattby Sporthall",
    3744: "Telefonplanshallen",
    1332: "Tibblehallen CC",
    1296: "Tomtbergahallen",
    1306: "Torvalla Sporthall",
    1308: "Torvalla Träningshall",
    4094: "Torsviks Idrottshall",
    1354: "Trollbäckshallen",
    1280: "Tyresöhallen",
    1274: "Tullingehallen",
    1342: "Tungelsta Sporthall",
    3997: "Töjnahallen",
    2067: "Ulriksdalshallen",
    1322: "Vaxholm Innebandyhallen",
    1307: "Vendelsömalmshallen",
    1331: "Vikingavallen Täby IP",
    1246: "Viksjö Sporthall",
    2929: "Vintervikshallen",
    1245: "Vällingbyhallen",
    1273: "Värmdö Sporthall",
    1244: "Väsby Skola",
    1243: "Västertorpshallen",
    3604: "Åbyhallen",
    1241: "Åkersberga Sporthall",
    1238: "Ärvingehallen",
    4248: "Österåkers Multiarena 1",
    4249: "Österåkers Multiarena 2",
  };

  static String getNameById(int id) {
    return facilities[id] ?? "Facility not found";
  }

  static int getIdByName(String query) {
    query = query.toLowerCase();
    List<int> matchingIds = [];

    for (var entry in ArenasInStockholm.facilities.entries) {
      if (entry.value.toLowerCase().contains(query)) {
        matchingIds.add(entry.key);
      }
    }

    if (matchingIds.length == 1) {
      return matchingIds.first;
    }
    if (matchingIds.length > 1) {
      throw Exception("Error: Multiple facilities found for query '$query'");
    } else {
      throw Exception("Error: No facilities found for query '$query'");
    }
  }

  static List<String> getFacilitiesList() {
    return facilities.values.toList(); // Convert map values to list
  }
}