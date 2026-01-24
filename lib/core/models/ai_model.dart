/// Represents an AI model available from the Soundboard API.
class AiModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final bool supportsTemperature;

  const AiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.supportsTemperature,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      supportsTemperature: json['supportsTemperature'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'supportsTemperature': supportsTemperature,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
