import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';

final voiceManagerProvider = StateProvider<int>((ref) {
  return SettingsBox().azVoiceId;
});

class Voice {
  final int id;
  final String name;
  final String shortName;

  Voice({required this.id, required this.name, required this.shortName});
}

class VoiceManager {
  static List<Voice> voices = [
    Voice(id: 1, name: "Sofie", shortName: "sv-SE-SofieNeural"),
    Voice(id: 2, name: "Mattias", shortName: "sv-SE-MattiasNeural"),
    Voice(id: 3, name: "Hillevi", shortName: "sv-SE-HilleviNeural"),
    Voice(
      id: 4,
      name: "Ava Multilingual (experimental)",
      shortName: "en-US-NovaTurboMultilingualNeural",
    ),
  ];

  // Method to get a list of all names
  static List<String> getVoiceList() {
    return voices.map((voice) => voice.name).toList();
  }

  // Other methods can also be made static as needed
  static int getIdByName(String name) {
    for (var voice in voices) {
      if (voice.name == name) {
        return voice.id;
      }
    }
    return -1; // Return -1 if the name is not found
  }

  static String getNameById(int id) {
    for (var voice in voices) {
      if (voice.id == id) {
        return voice.name;
      }
    }
    return 'Name not found'; // Return a message if the ID is not found
  }

  static String getAzVoiceName(int id) {
    for (var voice in voices) {
      if (voice.id == id) {
        return voice.shortName;
      }
    }
    return 'Short name not found'; // Return a message if the ID is not found
  }
}
