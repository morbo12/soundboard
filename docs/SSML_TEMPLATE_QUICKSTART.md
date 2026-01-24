# SSML Template Quick Start Guide

Get started with customizable SSML templates in 5 minutes!

## What Are SSML Templates?

SSML templates allow you to customize how the soundboard announces:

- **Welcome messages** - Initial greeting with venue and team names
- **Team lineups** - Player names, numbers, and coaching staff
- **Referee announcements** - Match officials

## Quick Start

### Step 1: Access Template Settings

1. Open the soundboard application
2. Navigate to **Settings**
3. Scroll to **SSML Templates** section
4. Click **Edit SSML Templates**

### Step 2: Choose a Template to Edit

Three tabs are available:

- **Welcome** - Match introduction
- **Lineup** - Team roster announcement
- **Referee** - Officials announcement

### Step 3: Understand the Basics

Templates use `{{variableName}}` for dynamic content:

```xml
Välkomna till {{venue}}!
```

Will become:

```xml
Välkomna till Lyckeby Sporthall!
```

### Step 4: Use Loops for Players

To announce multiple players, use loops:

```xml
{{#players}}
Nummer {{shirtNo}}, {{name}}<break time="500ms"/>
{{/players}}
```

### Step 5: Add Conditionals

Show different content for goalkeepers vs field players:

```xml
{{#isGoalkeeper}}
Målvakt: {{name}}
{{/isGoalkeeper}}
{{^isGoalkeeper}}
Utespelare: {{name}}
{{/isGoalkeeper}}
```

### Step 6: Save and Test

1. Click **Save Template**
2. Enable **SSML Preview** in settings
3. Test your template by playing a lineup

## Common Customizations

### Change Welcome Message Language

**Default:**

```xml
Välkomna till {{venue}}!
```

**English:**

```xml
Welcome to {{venue}}!
```

### Customize Player Announcement Format

**Default:**

```xml
Nummer {{shirtNo}}, <say-as interpret-as="name">{{name}}</say-as>
```

**Alternative (name first):**

```xml
<say-as interpret-as="name">{{name}}</say-as>, nummer {{shirtNo}}
```

### Add Custom Messages

You can add any text to templates:

```xml
{{teamName}} ställer upp med följande spelare<break time="750ms"/>
Lycka till {{teamName}}!<break time="500ms"/>
{{#players}}
...
{{/players}}
```

## Available Variables

### Welcome Template

- `{{venue}}` - Venue name
- `{{homeTeam}}` - Home team
- `{{awayTeam}}` - Away team
- `{{voiceName}}` - Voice identifier

### Lineup Template

- `{{teamName}}` - Team name
- `{{voiceName}}` - Voice identifier
- Inside `{{#players}}...{{/players}}`:
  - `{{name}}` - Player name
  - `{{shirtNo}}` - Jersey number
  - `{{isGoalkeeper}}` - Is goalkeeper (true/false)
  - `{{hasShirtNo}}` - Has shirt number (true/false)
- Inside `{{#teamPersons}}...{{/teamPersons}}`:
  - `{{name}}` - Staff member name

### Referee Template

- `{{referee1}}` - First referee
- `{{referee2}}` - Second referee
- `{{voiceName}}` - Voice identifier

## Tips

✅ **DO:**

- Start with the default templates
- Make small changes and test
- Use the "Available Variables & Syntax" help in the UI
- Keep SSML structure intact (don't remove `<speak>` or `<voice>` tags)

❌ **DON'T:**

- Remove required SSML tags
- Use undefined variables
- Forget to close loops (`{{#loop}}` needs `{{/loop}}`)

## Troubleshooting

**Problem:** Template doesn't save  
**Solution:** Check for syntax errors, ensure all loops are closed

**Problem:** Variables show as `{{variable}}`  
**Solution:** Check spelling, variable names are case-sensitive

**Problem:** No audio plays  
**Solution:** Verify SSML structure is valid, use SSML Preview to debug

**Problem:** Want to reset to defaults  
**Solution:** Click "Reset to Default" button in template editor

## Next Steps

- Read [SSML_TEMPLATES.md](SSML_TEMPLATES.md) for detailed documentation
- Check [SSML_TEMPLATE_EXAMPLES.md](SSML_TEMPLATE_EXAMPLES.md) for more examples
- Explore [Azure SSML documentation](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/speech-synthesis-markup) for advanced features

## Support

If you need help:

1. Check the "Available Variables & Syntax" section in the template editor
2. Review the documentation files
3. Reset to defaults if something breaks
4. Test with SSML Preview before using in matches
