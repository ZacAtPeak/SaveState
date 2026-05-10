create table condition_types
(
    system_id   TEXT,
    id          INTEGER not null
        primary key,
    name        TEXT,
    description TEXT
);

create table entity_types
(
    id          TEXT not null
        primary key,
    name        TEXT not null
        unique,
    description TEXT
);

create table game_systems
(
    id                    TEXT    not null
        primary key,
    name                  TEXT    not null,
    action_economy_type   TEXT    not null,
    uses_bounded_accuracy INTEGER not null,
    check (action_economy_type IN ('Standard', 'Action_Points', 'Three_Action')),
    check (uses_bounded_accuracy IN (0, 1))
);

create table actors
(
    id              TEXT    not null
        primary key,
    system_id       TEXT    not null
        references game_systems
            on delete cascade,
    name            TEXT    not null,
    actor_type      TEXT    not null,
    base_hp         INTEGER not null,
    base_ac         INTEGER not null,
    stats_blob      TEXT,
    quick_view_blob JSON,
    check (actor_type IN ('Player', 'NPC', 'Hazard'))
);

create table abilities_and_actions
(
    id             TEXT    not null
        primary key,
    actor_id       TEXT    not null
        references actors
            on delete cascade,
    name           TEXT    not null,
    action_cost    INTEGER not null,
    traits         TEXT,
    effect_payload TEXT
);

create table encounter_combatants
(
    id                TEXT    not null
        primary key,
    encounter_id      TEXT    not null,
    actor_id          TEXT    not null
        references actors
            on delete cascade,
    initiative_score  REAL,
    current_hp        INTEGER not null,
    temporary_hp      INTEGER default 0,
    available_actions INTEGER
);

create table combatant_conditions
(
    id                  TEXT not null
        primary key,
    combatant_id        TEXT not null
        references encounter_combatants
            on delete cascade,
    condition_name      TEXT not null,
    value               INTEGER,
    duration_rounds     INTEGER,
    source_combatant_id TEXT
        references encounter_combatants
);

create table encounters
(
    id                  TEXT not null
        primary key,
    name                TEXT not null,
    status              TEXT not null,
    current_round       INTEGER default 1,
    active_combatant_id TEXT
        references encounter_combatants,
    check (status IN ('Draft', 'Active', 'Completed'))
);

create table combat_log
(
    id                  TEXT not null
        primary key,
    encounter_id        TEXT not null
        references encounters
            on delete cascade,
    source_combatant_id TEXT not null
        references encounter_combatants,
    target_combatant_id TEXT
        references encounter_combatants,
    action_id           TEXT
        references abilities_and_actions,
    event_type          TEXT not null,
    raw_roll            INTEGER,
    calculated_result   INTEGER,
    timestamp           DATETIME default CURRENT_TIMESTAMP,
    check (event_type IN ('Roll', 'Damage', 'Heal', 'Condition_Applied', 'Turn_Start'))
);

alter table encounter_combatants
    add foreign key(encounter_id) references encounters
    on
delete
cascade;

create table entity_entries
(
    id             TEXT not null
        primary key,
    entity_type_id TEXT not null
        references entity_types,
    name           TEXT not null,
    description    TEXT,
    system_id      TEXT
                        references game_systems
                            on delete set null,
    metadata_blob  TEXT,
    tags           JSON,
    entity_type    TEXT
);

create table actor_conditions
(
    actor_id     TEXT not null
        references entity_entries
            on delete cascade,
    condition_id TEXT not null,
    primary key (actor_id, condition_id)
);

create table actor_entity_relations
(
    actor_id     TEXT not null
        references actors
            on delete cascade,
    entity_id    TEXT not null
        references entity_entries
            on delete cascade,
    quantity     INTEGER default 1,
    is_equipped  INTEGER default 0,
    custom_notes TEXT,
    primary key (actor_id, entity_id),
    check (is_equipped IN (0, 1))
);

create table entity_tags
(
    entity_id TEXT not null
        references entity_entries
            on delete cascade,
    tag_name  TEXT not null,
    primary key (entity_id, tag_name)
);

create table location_data
(
    entity_id          TEXT not null
        primary key
        references entity_entries
            on delete cascade,
    parent_location_id TEXT
        references location_data,
    is_discovered      INTEGER default 0,
    coordinate_blob    TEXT,
    check (is_discovered IN (0, 1))
);

create table skills
(
    id              TEXT not null
        primary key,
    system_id       TEXT not null
        references game_systems
            on delete cascade,
    name            TEXT not null,
    description     TEXT,
    associated_stat TEXT,
    mechanics_blob  TEXT
);

create table actors_skills
(
    actor_id          TEXT not null
        references actors
            on delete cascade,
    skill_id          TEXT not null
        references skills
            on delete cascade,
    base_value        INTEGER default 0,
    proficiency_level TEXT,
    modifier          INTEGER default 0,
    primary key (actor_id, skill_id)
);

create table systems
(
    system_id     INTEGER
        primary key,
    name          TEXT not null
        unique,
    version       TEXT,
    mechanic_type TEXT
);

create table tags
(
    tag_id INTEGER
        primary key,
    name   TEXT not null
        unique
);

