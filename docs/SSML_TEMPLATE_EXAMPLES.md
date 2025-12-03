# SSML Template Examples

This file contains examples of how to use the SSML template system with different scenarios.

## Example 1: Basic Welcome Message

**Template:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
Välkomna till {{venue}}!
</voice>
</speak>
```

**Data:**

- venue: "Lyckeby Sporthall"
- voiceName: "en-US-RyanMultilingualNeural"

**Output:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="en-US-RyanMultilingualNeural">
Välkomna till Lyckeby Sporthall!
</voice>
</speak>
```

## Example 2: Welcome with Teams

**Template:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
Välkomna till {{venue}}!
<break time="1000ms"/>
Idag möts {{homeTeam}} och {{awayTeam}} i en spännande match!
</voice>
</speak>
```

**Data:**

- venue: "Lyckeby Sporthall"
- homeTeam: "IFK Haninge"
- awayTeam: "Värmdö IF"
- voiceName: "en-US-RyanMultilingualNeural"

**Output:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="en-US-RyanMultilingualNeural">
Välkomna till Lyckeby Sporthall!
<break time="1000ms"/>
Idag möts IFK Haninge och Värmdö IF i en spännande match!
</voice>
</speak>
```

## Example 3: Lineup with Loop

**Template:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
{{teamName}} ställer upp med följande spelare:
{{#players}}
Nummer {{shirtNo}}, <say-as interpret-as="name">{{name}}</say-as><break time="500ms"/>
{{/players}}
</voice>
</speak>
```

**Data:**

- teamName: "IFK Haninge"
- voiceName: "en-US-RyanMultilingualNeural"
- players:
  - { name: "Carl Lövström", shirtNo: 2 }
  - { name: "Linus Ohlson", shirtNo: 4 }
  - { name: "Jakob Hägglund", shirtNo: 7 }

**Output:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="en-US-RyanMultilingualNeural">
IFK Haninge ställer upp med följande spelare:
Nummer 2, <say-as interpret-as="name">Carl Lövström</say-as><break time="500ms"/>
Nummer 4, <say-as interpret-as="name">Linus Ohlson</say-as><break time="500ms"/>
Nummer 7, <say-as interpret-as="name">Jakob Hägglund</say-as><break time="500ms"/>
</voice>
</speak>
```

## Example 4: Conditional Rendering (Goalkeeper)

**Template:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
{{teamName}} spelare:
{{#players}}
{{#isGoalkeeper}}
Målvakt: <say-as interpret-as="name">{{name}}</say-as><break time="500ms"/>
{{/isGoalkeeper}}
{{^isGoalkeeper}}
Utespelare nummer {{shirtNo}}, <say-as interpret-as="name">{{name}}</say-as><break time="500ms"/>
{{/isGoalkeeper}}
{{/players}}
</voice>
</speak>
```

**Data:**

- teamName: "IFK Haninge"
- voiceName: "en-US-RyanMultilingualNeural"
- players:
  - { name: "Gabriel Aspberg", shirtNo: 30, isGoalkeeper: true }
  - { name: "Carl Lövström", shirtNo: 2, isGoalkeeper: false }
  - { name: "Linus Ohlson", shirtNo: 4, isGoalkeeper: false }

**Output:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="en-US-RyanMultilingualNeural">
IFK Haninge spelare:
Målvakt: <say-as interpret-as="name">Gabriel Aspberg</say-as><break time="500ms"/>
Utespelare nummer 2, <say-as interpret-as="name">Carl Lövström</say-as><break time="500ms"/>
Utespelare nummer 4, <say-as interpret-as="name">Linus Ohlson</say-as><break time="500ms"/>
</voice>
</speak>
```

## Example 5: Complete Lineup with Staff

**Template:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="{{voiceName}}">
{{teamName}} ställer upp med följande spelare<break time="750ms"/>
{{#players}}
{{^isGoalkeeper}}
Nummer {{shirtNo}}, <say-as interpret-as="name">{{name}}</say-as><break time="750ms"/>
{{/isGoalkeeper}}
{{/players}}
{{#players}}
{{#isGoalkeeper}}
Dagens målvakt är <say-as interpret-as="name">{{name}}</say-as><break time="500ms"/>
{{/isGoalkeeper}}
{{/players}}
<break time="500ms"/>
Ledare för {{teamName}} är<break time="750ms"/>
{{#teamPersons}}
<say-as interpret-as="name">{{name}}</say-as><break time="750ms"/>
{{/teamPersons}}
</voice>
</speak>
```

**Data:**

- teamName: "IFK Haninge"
- voiceName: "en-US-RyanMultilingualNeural"
- players:
  - { name: "Carl Lövström", shirtNo: 2, isGoalkeeper: false }
  - { name: "Linus Ohlson", shirtNo: 4, isGoalkeeper: false }
  - { name: "Gabriel Aspberg", shirtNo: 30, isGoalkeeper: true }
- teamPersons:
  - { name: "Christian Hägglund" }
  - { name: "Dante Sahlen" }

**Output:**

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="en-US-RyanMultilingualNeural">
IFK Haninge ställer upp med följande spelare<break time="750ms"/>
Nummer 2, <say-as interpret-as="name">Carl Lövström</say-as><break time="750ms"/>
Nummer 4, <say-as interpret-as="name">Linus Ohlson</say-as><break time="750ms"/>
Dagens målvakt är <say-as interpret-as="name">Gabriel Aspberg</say-as><break time="500ms"/>
<break time="500ms"/>
Ledare för IFK Haninge är<break time="750ms"/>
<say-as interpret-as="name">Christian Hägglund</say-as><break time="750ms"/>
<say-as interpret-as="name">Dante Sahlen</say-as><break time="750ms"/>
</voice>
</speak>
```

## Tips for Creating Templates

1. **Always test with real data** - Use the SSML preview feature to verify output
2. **Use consistent formatting** - Keep pauses and timing consistent across templates
3. **Consider edge cases** - What happens if a list is empty? Use conditionals to handle this
4. **Keep it simple** - Start with basic templates and add complexity as needed
5. **Use Swedish names correctly** - The `<say-as interpret-as="name">` tag helps with pronunciation
6. **Add appropriate pauses** - Use `<break time="XXXms"/>` to make announcements clearer

## Common Patterns

### Handling Optional Fields

```xml
{{#fieldName}}
  Content when field exists
{{/fieldName}}
{{^fieldName}}
  Content when field is missing/false
{{/fieldName}}
```

### Iterating with Index

Mustache doesn't provide indices, but you can structure your data to include them:

```javascript
players: [
  { index: 1, name: "Player 1" },
  { index: 2, name: "Player 2" },
];
```

### Nested Loops

```xml
{{#teams}}
  Team: {{teamName}}
  {{#players}}
    Player: {{name}}
  {{/players}}
{{/teams}}
```
