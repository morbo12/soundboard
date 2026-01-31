import 'package:hive/hive.dart';
import 'team_profile.dart';

class TeamProfileAdapter extends TypeAdapter<TeamProfile> {
  @override
  final int typeId = 100;

  @override
  TeamProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return TeamProfile(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String? ?? '',
      colorTheme: fields[3] as String?,
      logoPath: fields[4] as String?,
      sponsorEnabled: fields[5] as bool? ?? false,
      mainSponsor: fields[6] as String? ?? '',
      otherSponsors: (fields[7] as List?)?.cast<String>() ?? [],
      kioskEnabled: fields[8] as bool? ?? false,
      kioskMessage: fields[9] as String? ?? 'Kiosken är öppen, välkommen att besöka oss under pausen!',
      homeJingleFilePath: fields[10] as String? ?? '',
      awayJingleFilePath: fields[11] as String? ?? '',
      gridColumns: fields[12] as int? ?? 3,
      gridRows: fields[13] as int? ?? 4,
      ssmlWelcomeTemplate: fields[14] as String?,
      ssmlLineupTemplate: fields[15] as String?,
      ssmlRefereeTemplate: fields[16] as String?,
      azVoiceName: fields[17] as String?,
      ttsVolume: fields[18] as double? ?? 0.3,
      backgroundVolumeLevel: fields[19] as double? ?? 0.1,
      mainVolume: fields[20] as double? ?? 0.3,
      spotifyUri: fields[21] as String?,
      spotifyUrl: fields[22] as String?,
      createdAt: fields[23] as DateTime?,
      lastUsed: fields[24] as DateTime?,
      isDefault: fields[25] as bool? ?? false,
      jingleAssignments: (fields[26] as Map?)?.cast<String, dynamic>() ?? {},
      // New fields (27-40)
      p1Volume: fields[27] as double? ?? 0.3,
      p2Volume: fields[28] as double? ?? 0.3,
      p3Volume: fields[29] as double? ?? 0.3,
      musicPlayerInitialVolume: fields[30] as double? ?? 0.1,
      apiProductKey: fields[31] as String? ?? '',
      apiDeviceId: fields[32] as String? ?? '',
      azTtsKey: fields[33] as String? ?? 'NoKey',
      azVoiceId: fields[34] as int? ?? 1,
      azRegionId: fields[35] as int? ?? 2,
      venueId: fields[36] as int? ?? 3455,
      federationId: fields[37] as int? ?? 8,
      serialPortName: fields[38] as String? ?? '',
      serialBaudRate: fields[39] as int? ?? 9600,
      serialAutoConnect: fields[40] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TeamProfile obj) {
    writer
      ..writeByte(41) // Number of fields (0-40)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.colorTheme)
      ..writeByte(4)
      ..write(obj.logoPath)
      ..writeByte(5)
      ..write(obj.sponsorEnabled)
      ..writeByte(6)
      ..write(obj.mainSponsor)
      ..writeByte(7)
      ..write(obj.otherSponsors)
      ..writeByte(8)
      ..write(obj.kioskEnabled)
      ..writeByte(9)
      ..write(obj.kioskMessage)
      ..writeByte(10)
      ..write(obj.homeJingleFilePath)
      ..writeByte(11)
      ..write(obj.awayJingleFilePath)
      ..writeByte(12)
      ..write(obj.gridColumns)
      ..writeByte(13)
      ..write(obj.gridRows)
      ..writeByte(14)
      ..write(obj.ssmlWelcomeTemplate)
      ..writeByte(15)
      ..write(obj.ssmlLineupTemplate)
      ..writeByte(16)
      ..write(obj.ssmlRefereeTemplate)
      ..writeByte(17)
      ..write(obj.azVoiceName)
      ..writeByte(18)
      ..write(obj.ttsVolume)
      ..writeByte(19)
      ..write(obj.backgroundVolumeLevel)
      ..writeByte(20)
      ..write(obj.mainVolume)
      ..writeByte(21)
      ..write(obj.spotifyUri)
      ..writeByte(22)
      ..write(obj.spotifyUrl)
      ..writeByte(23)
      ..write(obj.createdAt)
      ..writeByte(24)
      ..write(obj.lastUsed)
      ..writeByte(25)
      ..write(obj.isDefault)
      ..writeByte(26)
      ..write(obj.jingleAssignments)
      // New fields
      ..writeByte(27)
      ..write(obj.p1Volume)
      ..writeByte(28)
      ..write(obj.p2Volume)
      ..writeByte(29)
      ..write(obj.p3Volume)
      ..writeByte(30)
      ..write(obj.musicPlayerInitialVolume)
      ..writeByte(31)
      ..write(obj.apiProductKey)
      ..writeByte(32)
      ..write(obj.apiDeviceId)
      ..writeByte(33)
      ..write(obj.azTtsKey)
      ..writeByte(34)
      ..write(obj.azVoiceId)
      ..writeByte(35)
      ..write(obj.azRegionId)
      ..writeByte(36)
      ..write(obj.venueId)
      ..writeByte(37)
      ..write(obj.federationId)
      ..writeByte(38)
      ..write(obj.serialPortName)
      ..writeByte(39)
      ..write(obj.serialBaudRate)
      ..writeByte(40)
      ..write(obj.serialAutoConnect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
