import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'team_profile.g.dart';

/// Represents a team profile with individual settings, jingles, and preferences
/// Allows managing multiple teams on one installation
@HiveType(typeId: 100) // Use a unique typeId not conflicting with existing types
class TeamProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  // Visual/Branding
  @HiveField(3)
  String? colorTheme; // FlexColorScheme name

  @HiveField(4)
  String? logoPath; // Optional team logo

  // Sponsor & Kiosk
  @HiveField(5)
  bool sponsorEnabled;

  @HiveField(6)
  String mainSponsor;

  @HiveField(7)
  List<String> otherSponsors;

  @HiveField(8)
  bool kioskEnabled;

  @HiveField(9)
  String kioskMessage;

  // Lineup Jingles
  @HiveField(10)
  String homeJingleFilePath;

  @HiveField(11)
  String awayJingleFilePath;

  // Grid Layout
  @HiveField(12)
  int gridColumns;

  @HiveField(13)
  int gridRows;

  // SSML Templates
  @HiveField(14)
  String? ssmlWelcomeTemplate;

  @HiveField(15)
  String? ssmlLineupTemplate;

  @HiveField(16)
  String? ssmlRefereeTemplate;

  // TTS Settings
  @HiveField(17)
  String? azVoiceName;

  @HiveField(18)
  double ttsVolume;

  // Volume Settings
  @HiveField(19)
  double backgroundVolumeLevel;

  @HiveField(20)
  double mainVolume;

  // Spotify
  @HiveField(21)
  String? spotifyUri;

  @HiveField(22)
  String? spotifyUrl;

  // Metadata
  @HiveField(23)
  DateTime createdAt;

  @HiveField(24)
  DateTime lastUsed;

  @HiveField(25)
  bool isDefault;

  // Jingle Assignments (stored as Map<String, dynamic> for flexibility)
  // Key format: "row_col" (e.g., "0_0", "1_2")
  // Value: { "filePath": "...", "displayName": "...", "category": "..." }
  @HiveField(26)
  Map<String, dynamic> jingleAssignments;

  TeamProfile({
    String? id,
    required this.name,
    this.description = '',
    this.colorTheme,
    this.logoPath,
    this.sponsorEnabled = false,
    this.mainSponsor = '',
    this.otherSponsors = const [],
    this.kioskEnabled = false,
    this.kioskMessage = 'Kiosken är öppen, välkommen att besöka oss under pausen!',
    this.homeJingleFilePath = '',
    this.awayJingleFilePath = '',
    this.gridColumns = 6,
    this.gridRows = 5,
    this.ssmlWelcomeTemplate,
    this.ssmlLineupTemplate,
    this.ssmlRefereeTemplate,
    this.azVoiceName,
    this.ttsVolume = 1.0,
    this.backgroundVolumeLevel = 0.5,
    this.mainVolume = 1.0,
    this.spotifyUri,
    this.spotifyUrl,
    DateTime? createdAt,
    DateTime? lastUsed,
    this.isDefault = false,
    Map<String, dynamic>? jingleAssignments,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastUsed = lastUsed ?? DateTime.now(),
        jingleAssignments = jingleAssignments ?? {};

  /// Creates a copy of this profile with updated fields
  TeamProfile copyWith({
    String? name,
    String? description,
    String? colorTheme,
    String? logoPath,
    bool? sponsorEnabled,
    String? mainSponsor,
    List<String>? otherSponsors,
    bool? kioskEnabled,
    String? kioskMessage,
    String? homeJingleFilePath,
    String? awayJingleFilePath,
    int? gridColumns,
    int? gridRows,
    String? ssmlWelcomeTemplate,
    String? ssmlLineupTemplate,
    String? ssmlRefereeTemplate,
    String? azVoiceName,
    double? ttsVolume,
    double? backgroundVolumeLevel,
    double? mainVolume,
    String? spotifyUri,
    String? spotifyUrl,
    DateTime? lastUsed,
    bool? isDefault,
    Map<String, dynamic>? jingleAssignments,
  }) {
    return TeamProfile(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorTheme: colorTheme ?? this.colorTheme,
      logoPath: logoPath ?? this.logoPath,
      sponsorEnabled: sponsorEnabled ?? this.sponsorEnabled,
      mainSponsor: mainSponsor ?? this.mainSponsor,
      otherSponsors: otherSponsors ?? this.otherSponsors,
      kioskEnabled: kioskEnabled ?? this.kioskEnabled,
      kioskMessage: kioskMessage ?? this.kioskMessage,
      homeJingleFilePath: homeJingleFilePath ?? this.homeJingleFilePath,
      awayJingleFilePath: awayJingleFilePath ?? this.awayJingleFilePath,
      gridColumns: gridColumns ?? this.gridColumns,
      gridRows: gridRows ?? this.gridRows,
      ssmlWelcomeTemplate: ssmlWelcomeTemplate ?? this.ssmlWelcomeTemplate,
      ssmlLineupTemplate: ssmlLineupTemplate ?? this.ssmlLineupTemplate,
      ssmlRefereeTemplate: ssmlRefereeTemplate ?? this.ssmlRefereeTemplate,
      azVoiceName: azVoiceName ?? this.azVoiceName,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      backgroundVolumeLevel: backgroundVolumeLevel ?? this.backgroundVolumeLevel,
      mainVolume: mainVolume ?? this.mainVolume,
      spotifyUri: spotifyUri ?? this.spotifyUri,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      createdAt: createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isDefault: isDefault ?? this.isDefault,
      jingleAssignments: jingleAssignments ?? this.jingleAssignments,
    );
  }

  /// Updates the lastUsed timestamp
  void markAsUsed() {
    lastUsed = DateTime.now();
  }

  @override
  String toString() {
    return 'TeamProfile(id: $id, name: $name, isDefault: $isDefault)';
  }
}
