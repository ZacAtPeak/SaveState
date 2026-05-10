PRAGMA foreign_keys = ON;

-- ----------------------------
-- Source / rule text
-- ----------------------------
CREATE TABLE source_books (
    id INTEGER PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    edition TEXT,
    published_year INTEGER
);

CREATE TABLE book_sections (
    id INTEGER PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES source_books(id) ON DELETE CASCADE,
    parent_section_id INTEGER REFERENCES book_sections(id) ON DELETE CASCADE,
    kind TEXT NOT NULL CHECK (kind IN ('chapter','section','subsection','appendix','table','sidebar')),
    title TEXT NOT NULL,
    ordinal TEXT,
    body TEXT
);

CREATE TABLE rules_entries (
    id INTEGER PRIMARY KEY,
    section_id INTEGER REFERENCES book_sections(id) ON DELETE SET NULL,
    category TEXT NOT NULL CHECK (
        category IN (
            'core_rule','combat_rule','adventuring_rule','condition',
            'action','activity','glossary','variant_rule'
        )
    ),
    name TEXT NOT NULL,
    short_text TEXT,
    full_text TEXT NOT NULL,
    UNIQUE(category, name)
);

-- ----------------------------
-- Character options
-- ----------------------------
CREATE TABLE classes (
    id INTEGER PRIMARY KEY,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL UNIQUE,
    hit_die INTEGER NOT NULL,
    primary_ability TEXT,
    spellcasting_ability TEXT,
    armor_prof_text TEXT,
    weapon_prof_text TEXT,
    tool_prof_text TEXT,
    saving_throw_prof_text TEXT,
    skill_choice_count INTEGER DEFAULT 0,
    description TEXT
);

CREATE TABLE subclasses (
    id INTEGER PRIMARY KEY,
    class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL,
    unlock_level INTEGER,
    description TEXT,
    UNIQUE(class_id, name)
);

CREATE TABLE class_features (
    id INTEGER PRIMARY KEY,
    class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    subclass_id INTEGER REFERENCES subclasses(id) ON DELETE CASCADE,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    level INTEGER NOT NULL,
    name TEXT NOT NULL,
    feature_type TEXT NOT NULL CHECK (feature_type IN ('base','optional','subclass')),
    uses_formula TEXT,
    recharge TEXT,
    description TEXT NOT NULL,
    UNIQUE(class_id, subclass_id, level, name)
);

CREATE TABLE races (
    id INTEGER PRIMARY KEY,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL UNIQUE,
    size TEXT,
    speed_ft INTEGER,
    ability_score_text TEXT,
    language_text TEXT,
    description TEXT
);

CREATE TABLE subraces (
    id INTEGER PRIMARY KEY,
    race_id INTEGER NOT NULL REFERENCES races(id) ON DELETE CASCADE,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL,
    ability_score_text TEXT,
    description TEXT,
    UNIQUE(race_id, name)
);

CREATE TABLE backgrounds (
    id INTEGER PRIMARY KEY,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL UNIQUE,
    skill_prof_text TEXT,
    tool_prof_text TEXT,
    language_prof_text TEXT,
    equipment_text TEXT,
    feature_name TEXT,
    feature_text TEXT,
    description TEXT
);

CREATE TABLE feats (
    id INTEGER PRIMARY KEY,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL UNIQUE,
    prerequisite_text TEXT,
    description TEXT NOT NULL
);

-- ----------------------------
-- Proficiencies / reference data
-- ----------------------------
CREATE TABLE proficiencies (
    id INTEGER PRIMARY KEY,
    kind TEXT NOT NULL CHECK (kind IN ('skill','save','armor','weapon','tool','language')),
    name TEXT NOT NULL,
    UNIQUE(kind, name)
);

CREATE TABLE class_proficiencies (
    class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    proficiency_id INTEGER NOT NULL REFERENCES proficiencies(id) ON DELETE CASCADE,
    PRIMARY KEY (class_id, proficiency_id)
);

CREATE TABLE race_proficiencies (
    race_id INTEGER NOT NULL REFERENCES races(id) ON DELETE CASCADE,
    proficiency_id INTEGER NOT NULL REFERENCES proficiencies(id) ON DELETE CASCADE,
    PRIMARY KEY (race_id, proficiency_id)
);

CREATE TABLE background_proficiencies (
    background_id INTEGER NOT NULL REFERENCES backgrounds(id) ON DELETE CASCADE,
    proficiency_id INTEGER NOT NULL REFERENCES proficiencies(id) ON DELETE CASCADE,
    PRIMARY KEY (background_id, proficiency_id)
);

-- ----------------------------
-- Equipment / items
-- ----------------------------
CREATE TABLE item_categories (
    id INTEGER PRIMARY KEY,
    parent_id INTEGER REFERENCES item_categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE items (
    id INTEGER PRIMARY KEY,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    category_id INTEGER REFERENCES item_categories(id) ON DELETE SET NULL,
    item_type TEXT NOT NULL CHECK (
        item_type IN (
            'gear','weapon','armor','shield','tool','pack','consumable',
            'ammunition','focus','holy_symbol','vehicle','mount',
            'trade_good','magic_item','wondrous_item','potion','ring',
            'rod','staff','wand','scroll'
        )
    ),
    name TEXT NOT NULL UNIQUE,
    rarity TEXT,
    requires_attunement INTEGER NOT NULL DEFAULT 0 CHECK (requires_attunement IN (0,1)),
    cost_amount REAL,
    cost_unit TEXT CHECK (cost_unit IN ('cp','sp','ep','gp','pp')),
    weight_lb REAL,
    description TEXT
);

CREATE TABLE weapons (
    item_id INTEGER PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE,
    weapon_class TEXT NOT NULL CHECK (weapon_class IN ('simple','martial')),
    weapon_kind TEXT NOT NULL CHECK (weapon_kind IN ('melee','ranged')),
    damage_dice TEXT,
    damage_type TEXT,
    versatile_damage_dice TEXT,
    normal_range_ft INTEGER,
    long_range_ft INTEGER
);

CREATE TABLE weapon_properties (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE weapon_property_map (
    item_id INTEGER NOT NULL REFERENCES weapons(item_id) ON DELETE CASCADE,
    property_id INTEGER NOT NULL REFERENCES weapon_properties(id) ON DELETE CASCADE,
    value_text TEXT,
    PRIMARY KEY (item_id, property_id)
);

CREATE TABLE armors (
    item_id INTEGER PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE,
    armor_type TEXT NOT NULL CHECK (armor_type IN ('light','medium','heavy','shield')),
    base_ac INTEGER NOT NULL,
    dex_bonus_cap INTEGER,
    min_strength INTEGER,
    stealth_disadvantage INTEGER NOT NULL DEFAULT 0 CHECK (stealth_disadvantage IN (0,1))
);

CREATE TABLE tools (
    item_id INTEGER PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE,
    tool_type TEXT NOT NULL
);

CREATE TABLE pack_items (
    pack_item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    child_item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (pack_item_id, child_item_id)
);

CREATE TABLE magic_items (
    item_id INTEGER PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE,
    magic_item_type TEXT,
    charges INTEGER,
    recharge_text TEXT
);

-- ----------------------------
-- Spells
-- ----------------------------
CREATE TABLE spells (
    id INTEGER PRIMARY KEY,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL UNIQUE,
    level INTEGER NOT NULL CHECK (level BETWEEN 0 AND 9),
    school TEXT NOT NULL,
    ritual INTEGER NOT NULL DEFAULT 0 CHECK (ritual IN (0,1)),
    concentration INTEGER NOT NULL DEFAULT 0 CHECK (concentration IN (0,1)),
    casting_time_text TEXT NOT NULL,
    range_text TEXT NOT NULL,
    duration_text TEXT NOT NULL,
    components_v INTEGER NOT NULL DEFAULT 0 CHECK (components_v IN (0,1)),
    components_s INTEGER NOT NULL DEFAULT 0 CHECK (components_s IN (0,1)),
    components_m INTEGER NOT NULL DEFAULT 0 CHECK (components_m IN (0,1)),
    material_text TEXT,
    attack_type TEXT CHECK (attack_type IN ('melee','ranged','save','none')),
    save_ability TEXT,
    damage_type TEXT,
    description TEXT NOT NULL,
    higher_levels_text TEXT
);

CREATE TABLE spell_classes (
    spell_id INTEGER NOT NULL REFERENCES spells(id) ON DELETE CASCADE,
    class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    PRIMARY KEY (spell_id, class_id)
);

-- ----------------------------
-- Monsters
-- ----------------------------
CREATE TABLE monsters (
    id INTEGER PRIMARY KEY,
    source_book_id INTEGER REFERENCES source_books(id) ON DELETE SET NULL,
    source_page INTEGER,
    name TEXT NOT NULL UNIQUE,
    size TEXT NOT NULL,
    type TEXT NOT NULL,
    subtype TEXT,
    alignment TEXT,
    armor_class INTEGER,
    armor_text TEXT,
    hit_points INTEGER,
    hit_dice TEXT,
    challenge_rating TEXT,
    xp INTEGER,
    proficiency_bonus INTEGER,
    str_score INTEGER NOT NULL,
    dex_score INTEGER NOT NULL,
    con_score INTEGER NOT NULL,
    int_score INTEGER NOT NULL,
    wis_score INTEGER NOT NULL,
    cha_score INTEGER NOT NULL,
    passive_perception INTEGER,
    senses_text TEXT,
    languages_text TEXT,
    damage_vulnerabilities_text TEXT,
    damage_resistances_text TEXT,
    damage_immunities_text TEXT,
    condition_immunities_text TEXT
);

CREATE TABLE monster_speeds (
    monster_id INTEGER NOT NULL REFERENCES monsters(id) ON DELETE CASCADE,
    movement_type TEXT NOT NULL CHECK (movement_type IN ('walk','burrow','climb','fly','swim')),
    speed_ft INTEGER NOT NULL,
    PRIMARY KEY (monster_id, movement_type)
);

CREATE TABLE monster_saves (
    monster_id INTEGER NOT NULL REFERENCES monsters(id) ON DELETE CASCADE,
    ability TEXT NOT NULL CHECK (ability IN ('STR','DEX','CON','INT','WIS','CHA')),
    bonus INTEGER NOT NULL,
    PRIMARY KEY (monster_id, ability)
);

CREATE TABLE monster_skills (
    monster_id INTEGER NOT NULL REFERENCES monsters(id) ON DELETE CASCADE,
    skill_name TEXT NOT NULL,
    bonus INTEGER NOT NULL,
    PRIMARY KEY (monster_id, skill_name)
);

CREATE TABLE monster_traits (
    id INTEGER PRIMARY KEY,
    monster_id INTEGER NOT NULL REFERENCES monsters(id) ON DELETE CASCADE,
    trait_type TEXT NOT NULL CHECK (
        trait_type IN ('trait','action','bonus_action','reaction','legendary_action','lair_action')
    ),
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    recharge_text TEXT,
    attack_bonus INTEGER,
    save_dc INTEGER,
    description TEXT NOT NULL
);

-- ----------------------------
-- Search
-- ----------------------------
CREATE VIRTUAL TABLE search_index USING fts5(
    entity_type,
    entity_id UNINDEXED,
    title,
    body
);

-- ----------------------------
-- Useful indexes
-- ----------------------------
CREATE INDEX idx_book_sections_book_parent ON book_sections(book_id, parent_section_id);
CREATE INDEX idx_rules_entries_category_name ON rules_entries(category, name);

CREATE INDEX idx_class_features_class_level ON class_features(class_id, level);
CREATE INDEX idx_subclasses_class ON subclasses(class_id);

CREATE INDEX idx_items_type_name ON items(item_type, name);
CREATE INDEX idx_items_category ON items(category_id);
CREATE INDEX idx_weapons_class_kind ON weapons(weapon_class, weapon_kind);
CREATE INDEX idx_armors_type ON armors(armor_type);

CREATE INDEX idx_spells_level_school ON spells(level, school);
CREATE INDEX idx_spell_classes_class ON spell_classes(class_id);

CREATE INDEX idx_monsters_cr ON monsters(challenge_rating);
CREATE INDEX idx_monster_traits_monster_type ON monster_traits(monster_id, trait_type, sort_order);