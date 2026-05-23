<script lang="ts">
  import type { Background } from '$lib/types';

  const ALL_SKILLS = [
    { id: 'acr', name: 'Acrobatics', ability: 'DEX' },
    { id: 'ani', name: 'Animal Handling', ability: 'WIS' },
    { id: 'arc', name: 'Arcana', ability: 'INT' },
    { id: 'ath', name: 'Athletics', ability: 'STR' },
    { id: 'dec', name: 'Deception', ability: 'CHA' },
    { id: 'his', name: 'History', ability: 'INT' },
    { id: 'ins', name: 'Insight', ability: 'WIS' },
    { id: 'int', name: 'Intimidation', ability: 'CHA' },
    { id: 'inv', name: 'Investigation', ability: 'INT' },
    { id: 'med', name: 'Medicine', ability: 'WIS' },
    { id: 'nat', name: 'Nature', ability: 'INT' },
    { id: 'prc', name: 'Perception', ability: 'WIS' },
    { id: 'prf', name: 'Performance', ability: 'CHA' },
    { id: 'prs', name: 'Persuasion', ability: 'CHA' },
    { id: 'rel', name: 'Religion', ability: 'INT' },
    { id: 'slh', name: 'Sleight of Hand', ability: 'DEX' },
    { id: 'ste', name: 'Stealth', ability: 'DEX' },
    { id: 'sur', name: 'Survival', ability: 'WIS' },
  ];

  interface Props {
    selectedSkills: string[];
    skillPicks: number;
    selectedBackgroundId: string | null;
    backgrounds: Background[];
    onChange: (skills: string[]) => void;
  }

  let { selectedSkills, skillPicks, selectedBackgroundId, backgrounds, onChange }: Props = $props();

  // Use skillPicks directly from the prop (driven by DB data)

  // Determine background-granted skills
  function getBackgroundSkillIds(): string[] {
    if (!selectedBackgroundId) return [];
    const bg = backgrounds.find(b => b.id === selectedBackgroundId);
    if (!bg || !bg.skill_proficiencies) return [];
    try {
      return JSON.parse(bg.skill_proficiencies);
    } catch {
      return [];
    }
  }

  let backgroundSkillIds = $derived(getBackgroundSkillIds());

  let backgroundSkillCount = $derived(backgroundSkillIds.length);

  let maxSkillPicks = $derived(skillPicks + backgroundSkillCount);

  function toggleSkill(skillId: string) {
    const isBackgroundSkill = backgroundSkillIds.includes(skillId);
    const isSelected = selectedSkills.includes(skillId);

    if (isBackgroundSkill) {
      // Background skills are always selected
      return;
    }

    if (isSelected) {
      onChange(selectedSkills.filter(s => s !== skillId));
    } else if (selectedSkills.filter(s => !backgroundSkillIds.includes(s)).length < skillPicks) {
      onChange([...selectedSkills, skillId]);
    }
  }

  // When background changes, ensure background skills are included
  $effect(() => {
    const currentBgSkills = backgroundSkillIds;
    if (currentBgSkills.length > 0) {
      const skillsToAdd = currentBgSkills.filter(id => !selectedSkills.includes(id));
      if (skillsToAdd.length > 0) {
        onChange([...selectedSkills, ...skillsToAdd]);
      }
    }
  });

  let remainingPicks = $derived(skillPicks - selectedSkills.filter(s => !backgroundSkillIds.includes(s)).length);

  // Abilities for grouping
  const ABILITY_ORDER = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
  let groupedSkills = $derived(
    ABILITY_ORDER.map(ability => ({
      ability,
      skills: ALL_SKILLS.filter(s => s.ability === ability),
    })).filter(g => g.skills.length > 0)
  );
</script>

<div class="skill-picker">
  <div class="picks-info">
    <span>Skill Proficiencies</span>
    <span class="picks-count" class:exceeded={remainingPicks < 0}>
      {selectedSkills.filter(s => !backgroundSkillIds.includes(s)).length} / {skillPicks}
      {#if backgroundSkillCount > 0}
        <span class="bg-picks">(+{backgroundSkillCount} from background)</span>
      {/if}
    </span>
  </div>

  {#each groupedSkills as group}
    <div class="skill-group">
      <span class="group-label">{group.ability}</span>
      <div class="skills-row">
        {#each group.skills as skill}
          {@const isSelected = selectedSkills.includes(skill.id)}
          {@const isBackground = backgroundSkillIds.includes(skill.id)}
          <button
            class="skill-btn"
            class:selected={isSelected}
            class:background-skill={isBackground}
            class:disabled={!isSelected && remainingPicks <= 0 && !isBackground && !backgroundSkillIds.includes(skill.id)}
            onclick={() => toggleSkill(skill.id)}
            disabled={isBackground}
            title={isBackground ? 'Granted by background' : skill.name}
          >
            {skill.name}
          </button>
        {/each}
      </div>
    </div>
  {/each}
</div>

<style>
  .skill-picker {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .picks-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 11px;
    font-weight: 600;
    color: var(--muted);
  }

  .picks-count {
    font-weight: 700;
    color: var(--fg);
  }

  .picks-count.exceeded {
    color: oklch(70% 0.2 30);
  }

  .bg-picks {
    color: var(--muted);
    font-weight: 500;
    font-size: 10px;
  }

  .skill-group {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }

  .group-label {
    font-size: 9px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--muted);
  }

  .skills-row {
    display: flex;
    flex-wrap: wrap;
    gap: 3px;
  }

  .skill-btn {
    padding: 3px 8px;
    font-size: 10px;
    font-weight: 600;
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--muted);
    border-radius: 4px;
    cursor: pointer;
    transition: all 120ms;
  }

  .skill-btn:hover:not(:disabled) {
    border-color: var(--gold);
    color: var(--fg);
  }

  .skill-btn.selected {
    background: var(--gold);
    border-color: var(--gold);
    color: oklch(11% 0.012 250);
  }

  .skill-btn.background-skill {
    background: oklch(30% 0.05 250);
    border-color: oklch(40% 0.08 250);
    color: oklch(80% 0.06 250);
    cursor: default;
  }

  .skill-btn.disabled {
    opacity: 0.4;
    cursor: not-allowed;
  }
</style>
