import { invoke } from '@tauri-apps/api/core';
import type { Entity, PlayerCharacter, Creature, InitiativeEntity, CharacterSkill, CreateCharacterRequest, DiceRoll, SavedEncounter } from '$lib/types';

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
  let encounters = $state<SavedEncounter[]>([]);
  let showEncounterBuilder = $state(false);
  let diceHistory = $state<DiceRoll[]>([]);
  let characterStatuses = $state<Record<string, string[]>>({});
  let showCharacterModal = $state(false);
  let modalCharacter = $state<Entity | null>(null);

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
      instance_id: crypto.randomUUID(),
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

  async function saveEncounter(name: string, creatureSelections: { entityId: string; count: number }[]) {
    const encounter: SavedEncounter = {
      id: crypto.randomUUID(),
      name,
      creatures: creatureSelections.filter(c => c.count > 0)
    };
    encounters = [...encounters, encounter];
    try {
      await invoke('save_encounter', { data: encounter });
    } catch (e) {
      console.error('Failed to save encounter:', e);
    }
  }

  function deployEncounter(encounterId: string) {
    const encounter = encounters.find(e => e.id === encounterId);
    if (!encounter) return;
    for (const selection of encounter.creatures) {
      const creature = creatures.find(c => c.id === selection.entityId);
      if (!creature) continue;
      for (let i = 0; i < selection.count; i++) {
        addToInitiative(creature);
      }
    }
  }

  async function deleteEncounter(encounterId: string) {
    encounters = encounters.filter(e => e.id !== encounterId);
    try {
      await invoke('delete_encounter', { id: encounterId });
    } catch (e) {
      console.error('Failed to delete encounter:', e);
    }
  }

  async function loadEncounters() {
    try {
      encounters = await invoke<SavedEncounter[]>('load_encounters');
    } catch (e) {
      console.error('Failed to load encounters:', e);
    }
  }

  let modalInstanceId = $state<string | null>(null);
  let instanceStatOverrides = $state<Record<string, Record<string, number>>>({});

  function openCharacterModal(entity: Entity, instanceId?: string | null) {
    modalCharacter = entity;
    modalInstanceId = instanceId ?? null;
    showCharacterModal = true;
    if (entity.proficiency_bonus && !instanceId) {
      loadCharacterSkills(entity.id, entity.proficiency_bonus);
    }
    const statusKey = instanceId ?? entity.id;
    if (!characterStatuses[statusKey]) {
      characterStatuses = { ...characterStatuses, [statusKey]: [] };
    }
  }

  function closeCharacterModal() {
    showCharacterModal = false;
    modalCharacter = null;
    modalInstanceId = null;
  }

  function addStatus(entityId: string, status: string) {
    const current = characterStatuses[entityId] ?? [];
    if (!current.includes(status)) {
      characterStatuses = { ...characterStatuses, [entityId]: [...current, status] };
    }
  }

  function removeStatus(entityId: string, status: string) {
    const current = characterStatuses[entityId] ?? [];
    characterStatuses = { ...characterStatuses, [entityId]: current.filter(s => s !== status) };
  }

  function setInstanceStat(instanceId: string, key: string, value: number) {
    instanceStatOverrides = {
      ...instanceStatOverrides,
      [instanceId]: { ...instanceStatOverrides[instanceId], [key]: value }
    };
  }

  function clearInstanceStat(instanceId: string, key: string) {
    const current = instanceStatOverrides[instanceId];
    if (!current) return;
    const { [key]: _, ...rest } = current;
    instanceStatOverrides = { ...instanceStatOverrides, [instanceId]: rest };
  }

  function clearAllInstanceStats(instanceId: string) {
    const { [instanceId]: _, ...rest } = instanceStatOverrides;
    instanceStatOverrides = rest;
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

  function updateInitiativeInstanceHp(instanceId: string, delta: number) {
    initiativeList = initiativeList.map(entity => {
      if (entity.instance_id === instanceId) {
        const newHp = Math.max(0, Math.min(entity.hit_points_max, entity.hit_points_current + delta));
        return { ...entity, hit_points_current: newHp };
      }
      return entity;
    });
  }

  function setInitiativeInstanceHp(instanceId: string, current: number, max: number) {
    initiativeList = initiativeList.map(entity => {
      if (entity.instance_id === instanceId) {
        const clamped = Math.max(0, Math.min(max, current));
        return { ...entity, hit_points_current: clamped, hit_points_max: max };
      }
      return entity;
    });
  }

  function syncInitiativeInstanceFromOverrides(instanceId: string) {
    const overrides = instanceStatOverrides[instanceId];
    if (!overrides) return;
    initiativeList = initiativeList.map(entity => {
      if (entity.instance_id === instanceId) {
        return {
          ...entity,
          armor_class: overrides.armor_class ?? entity.armor_class,
          strength: overrides.strength ?? entity.strength,
          dexterity: overrides.dexterity ?? entity.dexterity,
          constitution: overrides.constitution ?? entity.constitution,
          intelligence: overrides.intelligence ?? entity.intelligence,
          wisdom: overrides.wisdom ?? entity.wisdom,
          charisma: overrides.charisma ?? entity.charisma,
          hit_points_current: overrides.hit_points_current ?? entity.hit_points_current,
          hit_points_max: overrides.hit_points_max ?? entity.hit_points_max,
        };
      }
      return entity;
    });
  }

  async function syncHpToDb(entityId: string, hitPointsCurrent: number) {
    try {
      await invoke('update_entity_hp', { entityId, hitPointsCurrent });
    } catch (e) {
      console.error('[DEBUG] Failed to sync HP to DB:', e);
    }
  }

  async function updateHp(entityId: string, delta: number) {
    const entity = playerCharacters.find(e => e.id === entityId)
      || npcs.find(e => e.id === entityId)
      || creatures.find(e => e.id === entityId);
    if (!entity) return;
    const newHp = Math.max(0, Math.min(entity.hit_points_max, entity.hit_points_current + delta));
    if (playerCharacters.find(e => e.id === entityId)) {
      playerCharacters = playerCharacters.map(e => e.id === entityId ? { ...e, hit_points_current: newHp } : e);
    } else if (npcs.find(e => e.id === entityId)) {
      npcs = npcs.map(e => e.id === entityId ? { ...e, hit_points_current: newHp } : e);
    } else if (creatures.find(e => e.id === entityId)) {
      creatures = creatures.map(e => e.id === entityId ? { ...e, hit_points_current: newHp } : e);
    }
    if (selectedCharacter && selectedCharacter.id === entityId) {
      selectedCharacter = { ...selectedCharacter, hit_points_current: newHp };
    }
    await syncHpToDb(entityId, newHp);
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
    updateInitiativeInstanceHp,
    setInitiativeInstanceHp,
    syncInitiativeInstanceFromOverrides,
    updateHp,
    syncHpToDb,
    get encounters() { return encounters; },
    set encounters(v) { encounters = v; },
    get showEncounterBuilder() { return showEncounterBuilder; },
    set showEncounterBuilder(v) { showEncounterBuilder = v; },
    saveEncounter,
    deployEncounter,
    deleteEncounter,
    loadEncounters,
    get characterStatuses() { return characterStatuses; },
    get showCharacterModal() { return showCharacterModal; },
    get modalCharacter() { return modalCharacter; },
    get modalInstanceId() { return modalInstanceId; },
    openCharacterModal,
    closeCharacterModal,
    addStatus,
    removeStatus,
    get instanceStatOverrides() { return instanceStatOverrides; },
    setInstanceStat,
    clearInstanceStat,
    clearAllInstanceStats,
  };
}

export const appStore = createAppStore();