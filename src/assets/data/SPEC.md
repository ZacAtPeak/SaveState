# Data Files Specification

## Directory Layout

```
src/assets/data/
├── index files (source-to-filename mappings)
│   ├── spells/
│   │   ├── index.json           # Source code → spell filename mapping
│   │   ├── fluff-index.json     # Source code → fluff filename mapping
│   │   ├── sources.json         # Spell → class availability by source
│   │   └── foundry.json        # Foundry-specific spell automation
│   └── class/
│       ├── index.json           # Class name → class filename mapping
│       └── fluff-index.json    # Class name → fluff filename mapping
│
├── root data files (single-type collections)
│   ├── actions.json            # Combat/action definitions
│   ├── backgrounds.json        # Character backgrounds
│   ├── conditionsdiseases.json  # Conditions and diseases
│   ├── feats.json              # Feat definitions
│   ├── items.json              # Magic items and equipment
│   ├── items-base.json        # Base equipment items
│   ├── languages.json          # Language definitions
│   ├── loot.json              # Loot tables
│   ├── optionalfeatures.json   # Optional class features
│   ├── races.json              # Race definitions
│   ├── recipes.json            # Crafting recipes
│   ├── rewards.json            # Party rewards
│   ├── skills.json            # Skill definitions (ability-based checks)
│   ├── tables.json            # Random tables
│   ├── trapshazards.json      # Traps and hazards
│   ├── vehicles.json          # Vehicle definitions
│   └── encounters.json        # Random encounter tables
│
├── root meta files (specialized data)
│   ├── encounterbuilder.json   # Encounter composition templates
│   ├── changelog.json        # Data change log
│   ├── makebrew-creature.json # Creature builder config
│   ├── makecards.json        # Card maker config
│   └── senses.json           # Sense type definitions
│
├── fluff files (narrative/descriptive content)
│   ├── fluff-backgrounds.json
│   ├── fluff-conditionsdiseases.json
│   ├── fluff-feats.json
│   ├── fluff-items.json
│   ├── fluff-languages.json
│   ├── fluff-objects.json
│   ├── fluff-races.json
│   ├── fluff-recipes.json
│   ├── fluff-trapshazards.json
│   └── fluff-vehicles.json
│
├── foundry files (Foundry VTT integration)
│   ├── foundry-actions.json
│   ├── foundry-feats.json
│   ├── foundry-items.json
│   ├── foundry-optionalfeatures.json
│   ├── foundry-races.json
│   └── foundry-rewards.json
│
├── subdirectories
│   ├── adventure/             # Adventure-specific data
│   ├── bestiary/             # Monster definitions
│   ├── book/                 # Book/source text content
│   ├── class/                # Class feature definitions
│   │   ├── class-*.json      # One file per class
│   │   └── fluff-class-*.json # One file per class (fluff)
│   ├── generated/            # Auto-generated data
│   └── spells/                # Spell definitions
│       ├── spells-*.json     # One file per source
│       ├── fluff-spells-*.json
│       └── foundry.json
```

---

## Index Files

### Spell Index (`spells/index.json`)
```json
{
  "PHB": "spells-phb.json",
  "XGE": "spells-xge.json"
}
```
Maps source codes to spell data files.

### Class Index (`class/index.json`)
```json
{
  "fighter": "class-fighter.json",
  "wizard": "class-wizard.json"
}
```
Maps class names to class data files.

---

## Data Structures

### Spell (`spells/spells-*.json`)
```typescript
{
  "spell": [
    {
      "name": string,           // Spell name
      "source": string,         // Source book code (e.g., "PHB")
      "page": number,           // Page number in source
      "level": number,          // 0 = cantrip, 1-9 = spell levels
      "school": string,         // School abbreviation (A=Abjuration, C=Conjuration, etc.)
      "time": [{               // Casting time(s)
        "number": number,
        "unit": "action" | "bonus" | "reaction" | "minute" | "hour"
      }],
      "range": {               // Target range
        "type": "point" | "sphere" | "cone" | "cube" | "line" | "self",
        "distance": {
          "type": "feet" | "mile" | "self" | "touch" | "unlimited",
          "amount": number
        }
      },
      "components": {           // Spell components
        "v": boolean,           // Verbal
        "s": boolean,          // Somatic
        "m": boolean | string  // Material (true or material description)
      },
      "duration": [{
        "type": "instant" | "concentration" | "permanent" | "time",
        "concentration": boolean,
        "duration": number
      }],
      "entries": [string | object],  // Spell description entries
      "damageInflict": string[],      // Damage types inflicted
      "savingThrow": string[],        // Required saving throws
      "miscTags": string[],           // Miscellaneous tags (SCL, SGT, etc.)
      "areaTags": string[],            // Area effect tags
      "srd": boolean,            // In SRD
      "basicRules": boolean,     // In Basic Rules
      "reprintedAs": string[],   // Reprinted in other sources
      "otherSources": [{         // Also appears in
        "source": string,
        "page": number
      }]
    }
  ]
}
```

### Class (`class/class-*.json`)
```typescript
{
  "_meta": {
    "internalCopies": ["subclass"]
  },
  "class": [
    {
      "name": string,
      "source": string,
      "page": number,
      "edition": "classic" | "modern",
      "hd": { "number": 1, "faces": 8 | 10 | 12 },
      "proficiency": string[],   // Ability scores (e.g., ["str", "con"])
      "optionalfeatureProgression": [{
        "name": string,
        "featureType": string[],
        "progression": { [level]: count }
      }],
      "startingProficiencies": {
        "armor": string[],
        "weapons": string[],
        "tools": string[],
        "skills": [{ "choose": { "from": string[], "count": number } }]
      },
      "startingEquipment": {
        "additionalFromBackground": boolean,
        "default": string[],
        "goldAlternative": string,
        "defaultData": object[]
      },
      "entries": [object]        // Class features and description
    }
  ]
}
```

### Feat (`feats.json`)
```typescript
{
  "feat": [
    {
      "name": string,
      "source": string,
      "page": number,
      "category": string,        // Feat category
      "prerequisite": [object],  // Prerequisites
      "ability": [{ [ability]: number }],  // Ability score increases
      "additionalSpells": [object],  // Granted spells
      "entries": [object]       // Feat description
    }
  ]
}
```

### Race (`races.json`)
```typescript
{
  "_meta": {
    "internalCopies": ["race", "subrace"]
  },
  "race": [
    {
      "name": string,
      "source": string,
      "page": number,
      "size": string[],         // "S", "M", "L", "H", "G"
      "speed": { "walk": number, "fly"?: number, "swim"?: number },
      "ability": [{ [ability]: number }],  // Ability score adjustments
      "age": { "mature": number, "max": number },
      "traitTags": string[],
      "languageProficiencies": [{ [language]: boolean | string }],
      "entries": [object]
    }
  ]
}
```

### Item (`items.json`)
```typescript
{
  "_meta": {
    "internalCopies": ["item"]
  },
  "item": [
    {
      "name": string,
      "source": string,
      "page": number,
      "type": string,            // Item type code (SCF=Spellcasting Focus, etc.)
      "rarity": string,
      "reqAttune": string,       // Attunement requirement
      "reqAttuneTags": [{ [tag]: value }],
      "wondrous": boolean,
      "weight": number,
      "focus": string[],
      "bonusSpellAttack": string,
      "bonusSpellSaveDc": string,
      "entries": [object]
    }
  ]
}
```

### Skill (`skills.json`)
```typescript
{
  "skill": [
    {
      "name": string,
      "source": string,
      "page": number,
      "ability": "str" | "dex" | "con" | "int" | "wis" | "cha",
      "srd": boolean,
      "basicRules": boolean,
      "reprintedAs": string[],
      "entries": [string | object]
    }
  ]
}
```

### Condition (`conditionsdiseases.json`)
```typescript
{
  "condition": [
    {
      "name": string,
      "source": string,
      "page": number,
      "srd": boolean,
      "basicRules": boolean,
      "otherSources": [{ "source": string, "page": number }],
      "reprintedAs": string[],
      "entries": [object],
      "hasFluffImages": boolean
    }
  ],
  "disease": [
    { /* Same structure as condition */ }
  ]
}
```

### Action (`actions.json`)
```typescript
{
  "action": [
    {
      "name": string,
      "source": string,
      "page": number,
      "srd": boolean,
      "basicRules": boolean,
      "time": [{ "number": number, "unit": string }],
      "entries": [object],
      "seeAlsoAction": string[]
    }
  ]
}
```

### Background (`backgrounds.json`)
```typescript
{
  "_meta": {
    "internalCopies": ["background"]
  },
  "background": [
    {
      "name": string,
      "source": string,
      "page": number,
      "edition": string,
      "ability": [object],      // Ability score selections
      "feats": [{ [featName]: boolean }],
      "skillProficiencies": [{ [skillName]: boolean }],
      "toolProficiencies": [{ [toolName]: boolean }],
      "languageProficiencies": [object],
      "startingEquipment": [object],
      "entries": [object]
    }
  ]
}
```

### Encounter Table (`encounters.json`)
```typescript
{
  "encounter": [
    {
      "name": string,
      "source": string,
      "page": number,
      "tables": [
        {
          "minlvl"?: number,
          "maxlvl"?: number,
          "diceExpression": string,  // e.g., "d100", "1d10"
          "table": [
            {
              "min": number,
              "max": number,
              "result": string      // Result text with 5e references
            }
          ]
        }
      ]
    }
  ]
}
```

### Encounter Builder (`encounterbuilder.json`)
```typescript
{
  "encounterShape": [
    {
      "name": string,           // "Boss", "Horde", "Duo", etc.
      "source": string,
      "shapeTemplate": [
        {
          "groups": [
            {
              "count": {
                "exact"?: number,
                "min"?: number,
                "max"?: number,
                "formulaMin"?: string,
                "formulaMax"?: string
              },
              "ratio": {
                "exact"?: number,
                "min"?: number,
                "max"?: number
              }
            }
          ]
        }
      ]
    }
  ]
}
```

### Book Content (`book/book-*.json`)
```typescript
{
  "data": [
    {
      "type": "section" | "entries" | "insetReadaloud",
      "name"?: string,
      "page"?: number,
      "data"?: { "quickref": number },
      "entries": [string | object],
      "id"?: string
    }
  ]
}
```

### Foundry Spell (`spells/foundry.json`)
```typescript
{
  "spell": [
    {
      "name": string,
      "source": string,
      "system": object,         // Foundry system config
      "activities": [
        {
          "type": "utility" | "save" | "damage" | "heal" | "attack" | "summon" | "transform",
          "name"?: string,
          "activation": { "type": string, "condition"?: string },
          "target": object,
          "range": object,
          "damage": object,
          "save": object,
          "effects": [{ "foundryId": string }]
        }
      ],
      "effects": [
        {
          "foundryId": string,
          "name": string,
          "duration": { "rounds"?: number, "seconds"?: number },
          "changes": [{ "key": string, "mode": string, "value": any }],
          "statuses": string[],
          "description": string,
          "disabled": boolean,
          "transfer": boolean
        }
      ],
      "migrationVersion": number
    }
  ]
}
```

### Sources (`spells/sources.json`)
Maps spells to class availability per source:
```typescript
{
  "PHB": {
    "Spell Name": {
      "class": [{ "name": string, "source": string }],
      "classVariant": [{ "name": string, "source": string, "definedInSource": string }]
    }
  }
}
```

---

## Common Patterns

### Entry Types (used in `entries` arrays)
```typescript
// List entries
{ "type": "list", "items": [...] }

// Titled entries
{ "type": "entries", "name": string, "entries": [...] }

// Entries with specific styling
{ "type": "list", "style": "list-hang-notitle", "items": [...] }

// Table
{ "type": "table", "colLabels": string[], "rows": [...] }

// Options/choices
{ "type": "options", "count": number, "from": string[], "entry": object }
```

### Reference Syntax
References use `{@book Name|Source|Page}` or `{@creature Name|Source}` format for cross-linking within the data.

### Source Codes
- PHB = Player's Handbook
- XGE = Xanathar's Guide to Everything
- TCE = Tasha's Cauldron of Everything
- XPHB = Expanded Player's Handbook
- DMG = Dungeon Master's Guide
- EGW = Exandria: Written in Blood (Eberron)
- And many others for specific campaign settings

### SRD Tags
- `srd`: Available in Systems Reference Document
- `basicRules`: In the free Basic Rules
- `srd52`: SRD 5.2 version
- `basicRules2024`: 2024 Basic Rules