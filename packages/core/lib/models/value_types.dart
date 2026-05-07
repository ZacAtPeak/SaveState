import 'enums.dart';

class AbilityScores {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const AbilityScores({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });

  int get strMod => _modifier(strength);
  int get dexMod => _modifier(dexterity);
  int get conMod => _modifier(constitution);
  int get intMod => _modifier(intelligence);
  int get wisMod => _modifier(wisdom);
  int get chaMod => _modifier(charisma);

  int modifierFor(String ability) {
    switch (ability.toLowerCase()) {
      case 'str':
        return strMod;
      case 'dex':
        return dexMod;
      case 'con':
        return conMod;
      case 'int':
        return intMod;
      case 'wis':
        return wisMod;
      case 'cha':
        return chaMod;
      default:
        return 0;
    }
  }

  static int _modifier(int score) => ((score - 10) / 2).floor();

  Map<String, dynamic> toJson() => {
        'strength': strength,
        'dexterity': dexterity,
        'constitution': constitution,
        'intelligence': intelligence,
        'wisdom': wisdom,
        'charisma': charisma,
      };

  factory AbilityScores.fromJson(Map<String, dynamic> json) => AbilityScores(
        strength: json['strength'] as int,
        dexterity: json['dexterity'] as int,
        constitution: json['constitution'] as int,
        intelligence: json['intelligence'] as int,
        wisdom: json['wisdom'] as int,
        charisma: json['charisma'] as int,
      );
}

class MovementSpeed {
  final int walk;
  final int? swim;
  final int? fly;
  final int? climb;
  final int? burrow;
  final bool hover;

  const MovementSpeed({
    required this.walk,
    this.swim,
    this.fly,
    this.climb,
    this.burrow,
    this.hover = false,
  });

  Map<String, dynamic> toJson() => {
        'walk': walk,
        'swim': swim,
        'fly': fly,
        'climb': climb,
        'burrow': burrow,
        'hover': hover,
      };

  factory MovementSpeed.fromJson(Map<String, dynamic> json) => MovementSpeed(
        walk: json['walk'] as int,
        swim: json['swim'] as int?,
        fly: json['fly'] as int?,
        climb: json['climb'] as int?,
        burrow: json['burrow'] as int?,
        hover: json['hover'] as bool? ?? false,
      );
}

class SavingThrowProficiencies {
  final bool strength;
  final bool dexterity;
  final bool constitution;
  final bool intelligence;
  final bool wisdom;
  final bool charisma;

  const SavingThrowProficiencies({
    this.strength = false,
    this.dexterity = false,
    this.constitution = false,
    this.intelligence = false,
    this.wisdom = false,
    this.charisma = false,
  });

  Map<String, dynamic> toJson() => {
        'strength': strength,
        'dexterity': dexterity,
        'constitution': constitution,
        'intelligence': intelligence,
        'wisdom': wisdom,
        'charisma': charisma,
      };

  factory SavingThrowProficiencies.fromJson(Map<String, dynamic> json) =>
      SavingThrowProficiencies(
        strength: json['strength'] as bool? ?? false,
        dexterity: json['dexterity'] as bool? ?? false,
        constitution: json['constitution'] as bool? ?? false,
        intelligence: json['intelligence'] as bool? ?? false,
        wisdom: json['wisdom'] as bool? ?? false,
        charisma: json['charisma'] as bool? ?? false,
      );
}

class Senses {
  final int? darkvision;
  final int? blindsight;
  final int? tremorsense;
  final int? truesight;
  final int passivePerception;

  const Senses({
    this.darkvision,
    this.blindsight,
    this.tremorsense,
    this.truesight,
    required this.passivePerception,
  });

  Map<String, dynamic> toJson() => {
        'darkvision': darkvision,
        'blindsight': blindsight,
        'tremorsense': tremorsense,
        'truesight': truesight,
        'passivePerception': passivePerception,
      };

  factory Senses.fromJson(Map<String, dynamic> json) => Senses(
        darkvision: json['darkvision'] as int?,
        blindsight: json['blindsight'] as int?,
        tremorsense: json['tremorsense'] as int?,
        truesight: json['truesight'] as int?,
        passivePerception: json['passivePerception'] as int,
      );
}

class SkillProficiency {
  final String skill;
  final bool isProficient;
  final int bonus;
  final String abilityScore;

  const SkillProficiency({
    required this.skill,
    required this.isProficient,
    required this.bonus,
    required this.abilityScore,
  });

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'isProficient': isProficient,
        'bonus': bonus,
        'abilityScore': abilityScore,
      };

  factory SkillProficiency.fromJson(Map<String, dynamic> json) =>
      SkillProficiency(
        skill: json['skill'] as String,
        isProficient: json['isProficient'] as bool,
        bonus: json['bonus'] as int,
        abilityScore: json['abilityScore'] as String,
      );
}

class SpecialAbility {
  final String name;
  final String description;

  const SpecialAbility({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory SpecialAbility.fromJson(Map<String, dynamic> json) => SpecialAbility(
        name: json['name'] as String,
        description: json['description'] as String,
      );
}

class Attack {
  final String id;
  final String name;
  final int hitBonus;
  final String reach;
  final String damageRoll;
  final DamageType damageType;
  final int? saveDC;
  final String? description;
  final int? maxUses;
  final int? remainingUses;

  const Attack({
    required this.id,
    required this.name,
    required this.hitBonus,
    required this.reach,
    required this.damageRoll,
    required this.damageType,
    this.saveDC,
    this.description,
    this.maxUses,
    this.remainingUses,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hitBonus': hitBonus,
        'reach': reach,
        'damageRoll': damageRoll,
        'damageType': damageType.name,
        'saveDC': saveDC,
        'description': description,
        'maxUses': maxUses,
        'remainingUses': remainingUses,
      };

  factory Attack.fromJson(Map<String, dynamic> json) => Attack(
        id: json['id'] as String,
        name: json['name'] as String,
        hitBonus: json['hitBonus'] as int,
        reach: json['reach'] as String,
        damageRoll: json['damageRoll'] as String,
        damageType: DamageType.values.byName(json['damageType'] as String),
        saveDC: json['saveDC'] as int?,
        description: json['description'] as String?,
        maxUses: json['maxUses'] as int?,
        remainingUses: json['remainingUses'] as int?,
      );
}

class LegendaryAction {
  final String name;
  final int cost;
  final String description;

  const LegendaryAction({
    required this.name,
    required this.cost,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'cost': cost,
        'description': description,
      };

  factory LegendaryAction.fromJson(Map<String, dynamic> json) =>
      LegendaryAction(
        name: json['name'] as String,
        cost: json['cost'] as int,
        description: json['description'] as String,
      );
}

class SpellSlot {
  final int level;
  final int max;
  final int available;

  const SpellSlot({
    required this.level,
    required this.max,
    required this.available,
  });

  Map<String, dynamic> toJson() => {
        'level': level,
        'max': max,
        'available': available,
      };

  factory SpellSlot.fromJson(Map<String, dynamic> json) => SpellSlot(
        level: json['level'] as int,
        max: json['max'] as int,
        available: json['available'] as int,
      );
}

class StatusCondition {
  final String name;
  final String effect;
  final String desc;

  const StatusCondition({
    required this.name,
    required this.effect,
    required this.desc,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'effect': effect,
        'desc': desc,
      };

  factory StatusCondition.fromJson(Map<String, dynamic> json) =>
      StatusCondition(
        name: json['name'] as String,
        effect: json['effect'] as String,
        desc: json['desc'] as String,
      );
}
