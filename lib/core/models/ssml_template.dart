/// Model class representing an SSML template
class SsmlTemplate {
  final String name;
  final String template;
  final String description;

  const SsmlTemplate({
    required this.name,
    required this.template,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'template': template,
    'description': description,
  };

  factory SsmlTemplate.fromJson(Map<String, dynamic> json) => SsmlTemplate(
    name: json['name'] as String,
    template: json['template'] as String,
    description: json['description'] as String,
  );

  SsmlTemplate copyWith({String? name, String? template, String? description}) {
    return SsmlTemplate(
      name: name ?? this.name,
      template: template ?? this.template,
      description: description ?? this.description,
    );
  }
}

/// Default SSML templates
class DefaultSsmlTemplates {
  static const welcomeTemplate = SsmlTemplate(
    name: 'Welcome',
    description: 'Welcome message template',
    template: '''Välkomna till {{venue}}!
{{break:1000}}
{{homeTeam}} hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan {{homeTeam}} och {{awayTeam}}
{{break:1000}}''',
  );

  static const lineupTemplate = SsmlTemplate(
    name: 'Lineup',
    description: 'Team lineup template',
    template: '''{{teamName}} ställer upp med följande spelare{{break:750}}
{{#players}}
{{#isGoalkeeper}}
Dagens målvakt är {{nameOpen}}{{name}}{{nameClose}}{{break:500}}
{{/isGoalkeeper}}
{{^isGoalkeeper}}
{{#hasShirtNo}}
Nummer {{shirtNo}}, {{nameOpen}}{{name}}{{nameClose}}{{break:750}}
{{/hasShirtNo}}
{{^hasShirtNo}}
{{nameOpen}}{{name}}{{nameClose}}{{break:750}}
{{/hasShirtNo}}
{{/isGoalkeeper}}
{{/players}}
{{break:500}}
Ledare för {{teamName}} är{{break:750}}
{{#teamPersons}}
{{nameOpen}}{{name}}{{nameClose}}{{break:1000}}
{{/teamPersons}}
{{break:1000}}''',
  );

  static const refereeTemplate = SsmlTemplate(
    name: 'Referee',
    description: 'Referee announcement template',
    template: '''Domare i denna match är,,
{{referee1}} och {{referee2}}''',
  );
}
