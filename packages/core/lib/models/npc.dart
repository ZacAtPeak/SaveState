import 'package:uuid/uuid.dart';

import 'enums.dart';
import 'value_types.dart';

class NPC {
  final String id;
  final String name;
  final String role;
  final CreatureSize size;
  final Alignment alignment;
  final String biography;
  final int armorClass;
  final String armorSource;
  final int currentHP;
  final int maxHP;
  final String hitDice;
  final MovementSpeed speed;
  final AbilityScores abilityScores;
  final int proficiencyBonus;
  final SavingThrowProficiencies savingThrowProficiencies;
  final List<SkillProficiency> skills;
  final List<DamageType> damageResistances;
  final List<DamageType> damageImmunities;
  final List<String> conditionImmunities;
  final Senses senses;
  final List<String> languages;
  final List<SpecialAbility> specialAbilities;
  final List<Attack> actions;
  final List<SpellSlot> spellSlots;
  final List<String> knownSpells;
  final double initiative;
  final List<StatusCondition>? status;

  NPC({
    String? id,
    required this.name,
    required this.role,
    required this.size,
    required this.alignment,
    required this.biography,
    required this.armorClass,
    required this.armorSource,
    required this.currentHP,
    required this.maxHP,
    required this.hitDice,
    required this.speed,
    required this.abilityScores,
    required this.proficiencyBonus,
    required this.savingThrowProficiencies,
    required this.skills,
    this.damageResistances = const [],
    this.damageImmunities = const [],
    this.conditionImmunities = const [],
    required this.senses,
    required this.languages,
    this.specialAbilities = const [],
    this.actions = const [],
    this.spellSlots = const [],
    this.knownSpells = const [],
    this.initiative = 0,
    this.status,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'size': size.name,
        'alignment': alignment.name,
        'biography': biography,
        'armorClass': armorClass,
        'armorSource': armorSource,
        'currentHP': currentHP,
        'maxHP': maxHP,
        'hitDice': hitDice,
        'speed': speed.toJson(),
        'abilityScores': abilityScores.toJson(),
        'proficiencyBonus': proficiencyBonus,
        'savingThrowProficiencies': savingThrowProficiencies.toJson(),
        'skills': skills.map((s) => s.toJson()).toList(),
        'damageResistances': damageResistances.map((d) => d.name).toList(),
        'damageImmunities': damageImmunities.map((d) => d.name).toList(),
        'conditionImmunities': conditionImmunities,
        'senses': senses.toJson(),
        'languages': languages,
        'specialAbilities': specialAbilities.map((a) => a.toJson()).toList(),
        'actions': actions.map((a) => a.toJson()).toList(),
        'spellSlots': spellSlots.map((s) => s.toJson()).toList(),
        'knownSpells': knownSpells,
        'initiative': initiative,
        'status': status?.map((s) => s.toJson()).toList(),
      };

  factory NPC.fromJson(Map<String, dynamic> json) => NPC(
        id: json['id'] as String?,
        name: json['name'] as String,
        role: json['role'] as String,
        size: CreatureSize.values.byName(json['size'] as String),
        alignment: Alignment.values.byName(json['alignment'] as String),
        biography: json['biography'] as String,
        armorClass: json['armorClass'] as int,
        armorSource: json['armorSource'] as String,
        currentHP: json['currentHP'] as int,
        maxHP: json['maxHP'] as int,
        hitDice: json['hitDice'] as String,
        speed: MovementSpeed.fromJson(Map<String, dynamic>.from(json['speed'] as Map)),
        abilityScores: AbilityScores.fromJson(Map<String, dynamic>.from(json['abilityScores'] as Map)),
        proficiencyBonus: json['proficiencyBonus'] as int,
        savingThrowProficiencies: SavingThrowProficiencies.fromJson(
            Map<String, dynamic>.from(json['savingThrowProficiencies'] as Map)),
        skills: (json['skills'] as List<dynamic>)
            .map((s) => SkillProficiency.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList(),
        damageResistances: (json['damageResistances'] as List<dynamic>?)
                ?.map((d) => DamageType.values.byName(d as String))
                .toList() ??
            [],
        damageImmunities: (json['damageImmunities'] as List<dynamic>?)
                ?.map((d) => DamageType.values.byName(d as String))
                .toList() ??
            [],
        conditionImmunities:
            (json['conditionImmunities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        senses: Senses.fromJson(Map<String, dynamic>.from(json['senses'] as Map)),
        languages: (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
        specialAbilities: (json['specialAbilities'] as List<dynamic>?)
                ?.map((a) => SpecialAbility.fromJson(Map<String, dynamic>.from(a as Map)))
                .toList() ??
            [],
        actions: (json['actions'] as List<dynamic>?)
                ?.map((a) => Attack.fromJson(Map<String, dynamic>.from(a as Map)))
                .toList() ??
            [],
        spellSlots: (json['spellSlots'] as List<dynamic>?)
                ?.map((s) => SpellSlot.fromJson(Map<String, dynamic>.from(s as Map)))
                .toList() ??
            [],
        knownSpells:
            (json['knownSpells'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        initiative: (json['initiative'] as num?)?.toDouble() ?? 0,
        status: (json['status'] as List<dynamic>?)
            ?.map((s) => StatusCondition.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList(),
      );
}
