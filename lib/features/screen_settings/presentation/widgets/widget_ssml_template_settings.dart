import 'package:flutter/material.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/models/ssml_template.dart';

/// Widget for editing SSML templates in settings
class SsmlTemplateSettings extends StatefulWidget {
  const SsmlTemplateSettings({super.key});

  @override
  State<SsmlTemplateSettings> createState() => _SsmlTemplateSettingsState();
}

class _SsmlTemplateSettingsState extends State<SsmlTemplateSettings>
    with SingleTickerProviderStateMixin {
  final _settings = SettingsBox();
  late TextEditingController _welcomeController;
  late TextEditingController _lineupController;
  late TextEditingController _refereeController;
  late TabController _tabController;
  bool _showHelp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _welcomeController = TextEditingController(
      text: _settings.ssmlWelcomeTemplate,
    );
    _lineupController = TextEditingController(
      text: _settings.ssmlLineupTemplate,
    );
    _refereeController = TextEditingController(
      text: _settings.ssmlRefereeTemplate,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _welcomeController.dispose();
    _lineupController.dispose();
    _refereeController.dispose();
    super.dispose();
  }

  void _saveTemplate(String type) {
    switch (type) {
      case 'welcome':
        _settings.ssmlWelcomeTemplate = _welcomeController.text;
        break;
      case 'lineup':
        _settings.ssmlLineupTemplate = _lineupController.text;
        break;
      case 'referee':
        _settings.ssmlRefereeTemplate = _refereeController.text;
        break;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Template saved')));
  }

  void _resetTemplate(String type) {
    setState(() {
      switch (type) {
        case 'welcome':
          _welcomeController.text =
              DefaultSsmlTemplates.welcomeTemplate.template;
          _settings.ssmlWelcomeTemplate =
              DefaultSsmlTemplates.welcomeTemplate.template;
          break;
        case 'lineup':
          _lineupController.text = DefaultSsmlTemplates.lineupTemplate.template;
          _settings.ssmlLineupTemplate =
              DefaultSsmlTemplates.lineupTemplate.template;
          break;
        case 'referee':
          _refereeController.text =
              DefaultSsmlTemplates.refereeTemplate.template;
          _settings.ssmlRefereeTemplate =
              DefaultSsmlTemplates.refereeTemplate.template;
          break;
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Template reset to default')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SSML Templates'),
        actions: [
          IconButton(
            icon: Icon(_showHelp ? Icons.help : Icons.help_outline),
            tooltip: _showHelp ? 'Hide Help' : 'Show Help',
            onPressed: () => setState(() => _showHelp = !_showHelp),
          ),
        ],
      ),
      body: Column(
        children: [
          // Compact tab selector
          Container(
            color: colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('Welcome'),
                        icon: Icon(Icons.waving_hand, size: 18),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('Lineup'),
                        icon: Icon(Icons.list, size: 18),
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text('Referee'),
                        icon: Icon(Icons.sports, size: 18),
                      ),
                    ],
                    selected: {_tabController.index},
                    onSelectionChanged: (Set<int> selection) {
                      setState(() {
                        _tabController.animateTo(selection.first);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Editor area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplateEditor(
                  'welcome',
                  _welcomeController,
                  'Welcome Message',
                  _getWelcomeHelp(),
                  Icons.waving_hand,
                  colorScheme.primaryContainer,
                ),
                _buildTemplateEditor(
                  'lineup',
                  _lineupController,
                  'Team Lineup',
                  _getLineupHelp(),
                  Icons.list,
                  colorScheme.secondaryContainer,
                ),
                _buildTemplateEditor(
                  'referee',
                  _refereeController,
                  'Referee Announcement',
                  _getRefereeHelp(),
                  Icons.sports,
                  colorScheme.tertiaryContainer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateEditor(
    String type,
    TextEditingController controller,
    String title,
    String help,
    IconData icon,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main editor area
        Expanded(
          flex: _showHelp ? 3 : 1,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Edit your SSML template',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Editor
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: TextField(
                        controller: controller,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Enter SSML template...',
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _resetTemplate(type),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _saveTemplate(type),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Help panel (when visible)
        if (_showHelp)
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Reference',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHelpContent(help, theme),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHelpContent(String help, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final sections = help.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        final lines = section.split('\n');
        final firstLine = lines[0].trim();

        // Check if this is a section header (ends with colon)
        final isHeader =
            firstLine.endsWith(':') &&
            !firstLine.startsWith('•') &&
            !firstLine.startsWith('{{') &&
            !firstLine.startsWith('Example:') &&
            !firstLine.startsWith('Note:');

        if (isHeader) {
          // Header with content below it
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstLine,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...lines.skip(1).map((line) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        } else if (firstLine.startsWith('Example:') ||
            firstLine.startsWith('Note:')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                section,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      }).toList(),
    );
  }

  String _getWelcomeHelp() {
    return '''Mustache Template Syntax:
• {{variable}} - Insert a variable value
• Variables use double curly braces
• Simple and straightforward syntax

Available Variables:
• {{venue}} - Venue name
• {{homeTeam}} - Home team name
• {{awayTeam}} - Away team name

Break Times (pauses):
• {{break:NUMBER}} - Custom break in milliseconds
  Examples: {{break:250}}, {{break:1000}}, {{break:1500}}

SSML Helper Tags:
• {{nameOpen}}text{{nameClose}} - Name pronunciation
• {{emphasisStrongOpen}}text{{emphasisStrongClose}} - Strong emphasis
• {{prosodySlowOpen}}text{{prosodySlowClose}} - Slow speech
• {{prosodyFastOpen}}text{{prosodyFastClose}} - Fast speech
• {{prosodyLoudOpen}}text{{prosodyLoudClose}} - Louder volume
• {{prosodySoftOpen}}text{{prosodySoftClose}} - Softer volume

Example:
Välkomna till {{venue}}!
{{break:1000}}
{{nameOpen}}{{homeTeam}}{{nameClose}} möter {{awayTeam}}

Note: SSML wrapper tags (<speak>, <voice>) are added automatically.''';
  }

  String _getLineupHelp() {
    return '''Mustache Template Syntax:
• {{variable}} - Insert a variable value
• {{#section}}...{{/section}} - Loop or conditional (if true)
• {{^section}}...{{/section}} - Inverted (if false)
• Loops repeat content for each item in a list

Available Variables:
• {{teamName}} - Team name

Loop through players:
{{#players}}
  • {{name}} - Player name
  • {{shirtNo}} - Shirt number
  • {{isGoalkeeper}} - true/false
  • {{hasShirtNo}} - true/false
{{/players}}

Loop through team staff:
{{#teamPersons}}
  • {{name}} - Person name
{{/teamPersons}}

Break Times (pauses):
• {{break:NUMBER}} - Custom break in milliseconds
  Examples: {{break:250}}, {{break:750}}, {{break:1000}}

SSML Helper Tags:
• {{nameOpen}}text{{nameClose}} - Name pronunciation
• {{emphasisStrongOpen}}text{{emphasisStrongClose}} - Strong emphasis
• {{prosodySlowOpen}}text{{prosodySlowClose}} - Slow speech
• {{prosodyFastOpen}}text{{prosodyFastClose}} - Fast speech
• {{prosodyLoudOpen}}text{{prosodyLoudClose}} - Louder volume
• {{prosodySoftOpen}}text{{prosodySoftClose}} - Softer volume

Conditionals:
{{#isGoalkeeper}}...{{/isGoalkeeper}}
{{^isGoalkeeper}}...{{/isGoalkeeper}}

Example:
Nummer {{shirtNo}}, {{nameOpen}}{{name}}{{nameClose}}{{break:750}}

Note: SSML wrapper tags (<speak>, <voice>) are added automatically.
You can also use raw SSML like <say-as interpret-as="name">''';
  }

  String _getRefereeHelp() {
    return '''Mustache Template Syntax:
• {{variable}} - Insert a variable value
• Variables use double curly braces
• Simple and straightforward syntax

Available Variables:
• {{referee1}} - First referee name
• {{referee2}} - Second referee name

Break Times (pauses):
• {{break:NUMBER}} - Custom break in milliseconds
  Examples: {{break:250}}, {{break:1000}}, {{break:1500}}

SSML Helper Tags:
• {{nameOpen}}text{{nameClose}} - Name pronunciation
• {{emphasisStrongOpen}}text{{emphasisStrongClose}} - Strong emphasis
• {{prosodySlowOpen}}text{{prosodySlowClose}} - Slow speech
• {{prosodyFastOpen}}text{{prosodyFastClose}} - Fast speech
• {{prosodyLoudOpen}}text{{prosodyLoudClose}} - Louder volume
• {{prosodySoftOpen}}text{{prosodySoftClose}} - Softer volume

Example:
Domare är {{nameOpen}}{{referee1}}{{nameClose}} och {{nameOpen}}{{referee2}}{{nameClose}}

Note: SSML wrapper tags (<speak>, <voice>) are added automatically.''';
  }
}
