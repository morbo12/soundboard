# SSML Template System

## Overview

The soundboard application now supports customizable SSML (Speech Synthesis Markup Language) templates for generating audio announcements. This allows you to customize the welcome message, team lineups, and referee announcements according to your preferences.

## Features

- **Template-based SSML Generation**: Use Mustache templates to define how announcements are structured
- **Dynamic Variables**: Insert team names, player information, venue details, and more
- **Loops**: Iterate over players and staff members with custom formatting
- **Conditionals**: Show/hide content based on conditions (e.g., goalkeeper vs. field players)
- **Easy Editing**: Edit templates directly in the settings UI with syntax help

## Available Templates

### 1. Welcome Template

Used for the initial match welcome announcement.

**Available Variables:**

- `{{venue}}` - The venue name
- `{{homeTeam}}` - Home team name
- `{{awayTeam}}` - Away team name
- `{{voiceName}}` - TTS voice identifier

**Example:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
Välkomna till {{venue}}!
<break time="1000ms"/>
{{homeTeam}} hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan {{homeTeam}} och {{awayTeam}}
<break time="1000ms"/>
</voice>
</speak>
```

### 2. Lineup Template

Used for announcing team lineups (both home and away teams).

**Available Variables:**

- `{{teamName}}` - The team name
- `{{voiceName}}` - TTS voice identifier

**Loop Variables (in `{{#players}}...{{/players}}`):**

- `{{name}}` - Player name
- `{{shirtNo}}` - Player's shirt number
- `{{isGoalkeeper}}` - Boolean, true if player is goalkeeper
- `{{hasShirtNo}}` - Boolean, true if player has a shirt number

**Loop Variables (in `{{#teamPersons}}...{{/teamPersons}}`):**

- `{{name}}` - Staff member name

**Example:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
{{teamName}} ställer upp med följande spelare<break time="750ms"/>
{{#players}}
{{#isGoalkeeper}}
Dagens målvakt är <say-as interpret-as="name">{{name}}</say-as><break time="500ms"/>
{{/isGoalkeeper}}
{{^isGoalkeeper}}
{{#hasShirtNo}}
Nummer {{shirtNo}}, <say-as interpret-as="name">{{name}}</say-as><break time="750ms"/>
{{/hasShirtNo}}
{{^hasShirtNo}}
<say-as interpret-as="name">{{name}}</say-as><break time="750ms"/>
{{/hasShirtNo}}
{{/isGoalkeeper}}
{{/players}}
<break time="500ms"/>
Ledare för {{teamName}} är<break time="750ms"/>
{{#teamPersons}}
<say-as interpret-as="name">{{name}}</say-as><break time="1000ms"/>
{{/teamPersons}}
<break time="1000ms"/>
</voice>
</speak>
```

### 3. Referee Template

Used for announcing the match referees.

**Available Variables:**

- `{{referee1}}` - First referee name
- `{{referee2}}` - Second referee name
- `{{voiceName}}` - TTS voice identifier

**Example:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
Domare i denna match är,,
{{referee1}} och {{referee2}}
</voice>
</speak>
```

## Mustache Template Syntax

The templates use [Mustache](http://mustache.github.io/) syntax, a simple and logic-less template system.

### Basic Variable Substitution

```
{{variableName}}
```

### Loops (Sections)

```
{{#listName}}
  Content repeated for each item
  {{itemProperty}}
{{/listName}}
```

### Conditionals

**If true (shows content when variable is true):**

```
{{#condition}}
  This shows when condition is true
{{/condition}}
```

**If false (shows content when variable is false):**

```
{{^condition}}
  This shows when condition is false
{{/condition}}
```

## How to Edit Templates

1. Navigate to **Settings** in the application
2. Find the **SSML Templates** section
3. Click **Edit SSML Templates**
4. Select the tab for the template you want to edit (Welcome, Lineup, or Referee)
5. Edit the template in the text editor
6. Use the "Available Variables & Syntax" help section for reference
7. Click **Save Template** to apply your changes
8. Click **Reset to Default** to restore the original template

## Tips

- Always include the SSML `<speak>` wrapper and `<voice>` tags
- Use `<break time="XXXms"/>` to add pauses in speech
- Use `<say-as interpret-as="name">` for proper name pronunciation
- Test your templates with the SSML Preview feature before using them
- Keep templates well-formatted for easier maintenance
- Use Swedish language (`xml:lang="sv-SE"`) for Swedish matches

## SSML Reference

Common SSML tags supported by Azure TTS:

- `<break time="500ms"/>` - Add a pause
- `<say-as interpret-as="name">` - Format as a name
- `<emphasis level="strong">` - Emphasize text
- `<prosody rate="slow">` - Change speech rate
- `<prosody pitch="high">` - Change pitch

For more SSML features, see the [Azure TTS SSML documentation](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/speech-synthesis-markup).

## Troubleshooting

**Template doesn't render correctly:**

- Check that all `{{variables}}` are spelled correctly
- Ensure all opening tags have matching closing tags
- Verify that loop sections are properly closed (`{{#loop}}...{{/loop}}`)

**No audio is generated:**

- Ensure the SSML XML structure is valid
- Check that required variables (like `voiceName`) are present
- Use the SSML Preview feature to test before playback

**Variables show as literal text:**

- Check variable spelling matches exactly
- Ensure variables are wrapped in double curly braces: `{{variable}}`

## Architecture

The template system consists of:

1. **SsmlTemplate Model** (`lib/core/models/ssml_template.dart`) - Data model for templates
2. **SsmlTemplateService** (`lib/core/services/ssml_template_service.dart`) - Renders templates with data
3. **SettingsBox Extensions** (`lib/core/properties.dart`) - Stores templates in local storage
4. **Settings UI** (`lib/features/screen_settings/presentation/widgets/widget_ssml_template_settings.dart`) - User interface for editing

Templates are stored in the application's local storage and persist between sessions.
