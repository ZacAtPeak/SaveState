import { invoke } from '@tauri-apps/api/core';
  import type { Entity, PlayerCharacter, Creature, InitiativeEntity, CharacterSkill, CreateCharacterRequest, DiceRoll } from '$lib/types';

function createAppStore() {
  let playerCharacters = $state<PlayerCharacter[]>([]);
  let creatures = $state<Creature[]>([]);
  let npcs = $state<Entity[]>([]);
  let selectedCharacter = $state<Entity | null>(null);
  let characterSkills = $state<CharacterSkill[]>([]);
  let initiativeList = $state<InitiativeEntity[]>([]);
  let loading = $state(true);
  let showSettings = $state(false);
  let showDiceRoller = $state(false);
  let showBook = $state(false);
  let showCreateCharacter = $state(false);
  let diceHistory = $state<DiceRoll[]>([]);

  let currentTurnIndex = $state(0);
  let currentRound = $state(1);

  let expandedSections = $state({
    characters: false,
    monsters: false,
    npcs: false,
    other: false
  });

  async function loadCharacters() {
    try {
      loading = true;
      console.log('[DEBUG] Loading characters...');
      const pcs = await invoke<PlayerCharacter[]>('get_player_characters');
      console.log('[DEBUG] Got', pcs.length, 'player characters');
      playerCharacters = pcs;
      const creaturesResult = await invoke<Creature[]>('get_monsters');
      console.log('[DEBUG] Got', creaturesResult.length, 'creatures');
      creatures = creaturesResult;
      const npcsResult = await invoke<Entity[]>('get_npcs');
      console.log('[DEBUG] Got', npcsResult.length, 'npcs');
      npcs = npcsResult;
      console.log('[DEBUG] Final state:', { pcs: playerCharacters.length, creatures: creatures.length, npcs: npcs.length });
      expandedSections.characters = true;
      expandedSections.monsters = true;
      expandedSections.npcs = true;
    } catch (e) {
      console.error('Failed to load characters:', e);
    } finally {
      loading = false;
    }
  }

  async function loadCharacterSkills(entityId: string, proficiencyBonus: number) {
    try {
      characterSkills = await invoke<CharacterSkill[]>('get_character_skills', {
        entityId,
        proficiencyBonus
      });
    } catch (e) {
      console.error('Failed to load character skills:', e);
    }
  }

  function selectCharacter(char: Entity) {
    selectedCharacter = char;
    if (char.proficiency_bonus) {
      loadCharacterSkills(char.id, char.proficiency_bonus);
    }
  }

  function toggleSection(section: keyof typeof expandedSections) {
    expandedSections[section] = !expandedSections[section];
  }

  function addToInitiative(char: Entity) {
    const dexMod = Math.floor((char.dexterity - 10) / 2);
    const initiative = Math.floor(Math.random() * 20) + 1 + dexMod;
    const newEntity: InitiativeEntity = {
      id: char.id,
      name: char.name,
      entity_type: char.entity_type,
      initiative,
      armor_class: char.armor_class,
      hit_points_current: char.hit_points_current,
      hit_points_max: char.hit_points_max,
      strength: char.strength,
      dexterity: char.dexterity,
      constitution: char.constitution,
      intelligence: char.intelligence,
      wisdom: char.wisdom,
      charisma: char.charisma
    };
    initiativeList = [...initiativeList, newEntity].sort((a, b) => b.initiative - a.initiative);
  }

  async function createCharacter(req: CreateCharacterRequest): Promise<PlayerCharacter> {
    const created = await invoke<PlayerCharacter>('create_player_character', { req });
    playerCharacters = [...playerCharacters, created];
    return created;
  }

  function rollDice(sides: number, count: number = 1, modifier: number = 0): DiceRoll {
    const results: number[] = [];
    for (let i = 0; i < count; i++) {
      results.push(Math.floor(Math.random() * sides) + 1);
    }
    const sum = results.reduce((a, b) => a + b, 0);
    const total = sum + modifier;

    let mathStr: string;
    if (count === 1) {
      mathStr = modifier !== 0 ? `${results[0]} ${modifier >= 0 ? '+' : ''}${modifier}` : `${results[0]}`;
    } else {
      const resultsStr = results.join(' + ');
      mathStr = modifier !== 0 ? `(${resultsStr}) ${modifier >= 0 ? '+' : ''}${modifier}` : resultsStr;
    }

    const roll: DiceRoll = {
      id: crypto.randomUUID(),
      dice: `d${sides}`,
      sides,
      count,
      results,
      modifier,
      math: mathStr,
      total,
      timestamp: Date.now()
    };
    diceHistory = [roll, ...diceHistory.slice(0, 49)];
    return roll;
  }

  function addDiceRoll(roll: DiceRoll) {
    diceHistory = [roll, ...diceHistory.slice(0, 49)];
  }

  function clearDiceHistory() {
    diceHistory = [];
  }

  function nextTurn() {
    if (initiativeList.length === 0) return;
    currentTurnIndex = (currentTurnIndex + 1) % initiativeList.length;
    if (currentTurnIndex === 0) {
      currentRound++;
    }
  }

  function prevTurn() {
    if (initiativeList.length === 0) return;
    if (currentTurnIndex === 0) {
      if (currentRound > 1) {
        currentRound--;
        currentTurnIndex = initiativeList.length - 1;
      }
    } else {
      currentTurnIndex--;
    }
  }

  function updateInitiativeHp(entityId: string, delta: number) {
    initiativeList = initiativeList.map(entity => {
      if (entity.id === entityId) {
        const newHp = Math.max(0, Math.min(entity.hit_points_max, entity.hit_points_current + delta));
        return { ...entity, hit_points_current: newHp };
      }
      return entity;
    });
    if (selectedCharacter && selectedCharacter.id === entityId) {
      selectedCharacter = {
        ...selectedCharacter,
        hit_points_current: Math.max(0, Math.min(selectedCharacter.hit_points_max, selectedCharacter.hit_points_current + delta))
      };
    }
  }

  return {
    get playerCharacters() { return playerCharacters; },
    set playerCharacters(v) { playerCharacters = v; },
    get creatures() { return creatures; },
    set creatures(v) { creatures = v; },
    get npcs() { return npcs; },
    set npcs(v) { npcs = v; },
    get selectedCharacter() { return selectedCharacter; },
    set selectedCharacter(v) { selectedCharacter = v; },
    get characterSkills() { return characterSkills; },
    set characterSkills(v) { characterSkills = v; },
    get initiativeList() { return initiativeList; },
    set initiativeList(v) { initiativeList = v; },
    get loading() { return loading; },
    set loading(v) { loading = v; },
    get showSettings() { return showSettings; },
    set showSettings(v) { showSettings = v; },
    get showDiceRoller() { return showDiceRoller; },
    set showDiceRoller(v) { showDiceRoller = v; },
    get showBook() { return showBook; },
    set showBook(v) { showBook = v; },
    get showCreateCharacter() { return showCreateCharacter; },
    set showCreateCharacter(v) { showCreateCharacter = v; },
    get diceHistory() { return diceHistory; },
    set diceHistory(v) { diceHistory = v; },
    get currentTurnIndex() { return currentTurnIndex; },
    set currentTurnIndex(v) { currentTurnIndex = v; },
    get currentRound() { return currentRound; },
    set currentRound(v) { currentRound = v; },
    get expandedSections() { return expandedSections; },
    set expandedSections(v) { expandedSections = v; },
    loadCharacters,
    loadCharacterSkills,
    selectCharacter,
    toggleSection,
    addToInitiative,
    createCharacter,
    rollDice,
    addDiceRoll,
    clearDiceHistory,
    nextTurn,
    prevTurn,
    updateInitiativeHp
  };
}

export const appStore = createAppStore();