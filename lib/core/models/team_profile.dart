import 'package:uuid/uuid.dart';

/// Represents a team profile with individual settings, jingles, and preferences
/// Allows managing multiple teams on one installation
class TeamProfile {
  final String id;
  String name;
  String description;

  // Visual/Branding
  String? colorTheme; // FlexColorScheme name
  String? logoPath; // Optional team logo

  // Sponsor & Kiosk
  bool sponsorEnabled;
  String mainSponsor;
  List<String> otherSponsors;
  bool kioskEnabled;
  String kioskMessage;

  // Lineup Jingles
  String homeJingleFilePath;
  String awayJingleFilePath;

  // Grid Layout
  int gridColumns;
  int gridRows;

  // SSML Templates
  String? ssmlWelcomeTemplate;
  String? ssmlLineupTemplate;
  String? ssmlRefereeTemplate;

  // TTS Settings
  String? azVoiceName;
  double ttsVolume;

  // Volume Settings
  double backgroundVolumeLevel;
  double mainVolume;
  double p1Volume;
  double p2Volume;
  double p3Volume;

  // Spotify
  String? spotifyUri;
  String? spotifyUrl;
  double musicPlayerInitialVolume;

  // API Settings
  String apiProductKey;
  String apiDeviceId;

  // Azure TTS Extended Settings
  String azTtsKey;
  int azVoiceId;
  int azRegionId;

  // Venue & Federation
  int venueId;
  int federationId;

  // Serial Port / Deej Settings
  String serialPortName;
  int serialBaudRate;
  bool serialAutoConnect;

  // Metadata
  DateTime createdAt;
  DateTime lastUsed;
  bool isDefault;

  // Jingle Assignments (stored as Map<String, dynamic> for flexibility)
  // Key format: position index (e.g., "0", "1", "2")
  // Value: GridJingleConfig JSON
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
    this.gridColumns = 3,
    this.gridRows = 4,
    this.ssmlWelcomeTemplate,
    this.ssmlLineupTemplate,
    this.ssmlRefereeTemplate,
    this.azVoiceName,
    this.ttsVolume = 0.3,
    this.backgroundVolumeLevel = 0.1,
    this.mainVolume = 0.3,
    this.p1Volume = 0.3,
    this.p2Volume = 0.3,
    this.p3Volume = 0.3,
    this.spotifyUri,
    this.spotifyUrl,
    this.musicPlayerInitialVolume = 0.1,
    this.apiProductKey = '',
    this.apiDeviceId = '',
    this.azTtsKey = 'NoKey',
    this.azVoiceId = 1,
    this.azRegionId = 2,
    this.venueId = 3455,
    this.federationId = 8,
    this.serialPortName = '',
    this.serialBaudRate = 9600,
    this.serialAutoConnect = false,
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
    double? p1Volume,
    double? p2Volume,
    double? p3Volume,
    String? spotifyUri,
    String? spotifyUrl,
    double? musicPlayerInitialVolume,
    String? apiProductKey,
    String? apiDeviceId,
    String? azTtsKey,
    int? azVoiceId,
    int? azRegionId,
    int? venueId,
    int? federationId,
    String? serialPortName,
    int? serialBaudRate,
    bool? serialAutoConnect,
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
      p1Volume: p1Volume ?? this.p1Volume,
      p2Volume: p2Volume ?? this.p2Volume,
      p3Volume: p3Volume ?? this.p3Volume,
      spotifyUri: spotifyUri ?? this.spotifyUri,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      musicPlayerInitialVolume: musicPlayerInitialVolume ?? this.musicPlayerInitialVolume,
      apiProductKey: apiProductKey ?? this.apiProductKey,
      apiDeviceId: apiDeviceId ?? this.apiDeviceId,
      azTtsKey: azTtsKey ?? this.azTtsKey,
      azVoiceId: azVoiceId ?? this.azVoiceId,
      azRegionId: azRegionId ?? this.azRegionId,
      venueId: venueId ?? this.venueId,
      federationId: federationId ?? this.federationId,
      serialPortName: serialPortName ?? this.serialPortName,
      serialBaudRate: serialBaudRate ?? this.serialBaudRate,
      serialAutoConnect: serialAutoConnect ?? this.serialAutoConnect,
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
