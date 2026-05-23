-- Seed data for Character Creation v2
-- Adds: races, race_ability_bonuses, subraces, backgrounds
-- Adds: missing classes (Bard, Cleric, Monk, Paladin, Ranger, Sorcerer, Warlock, Wizard)
-- Adds: subclasses for Rogue and all new classes

PRAGMA foreign_keys = ON;

-- ============================================================
-- RACES
-- ============================================================
INSERT OR IGNORE INTO races (id, name, description, size, speed_walk, darkvision, source) VALUES
('dwarf', 'Dwarf', 'Bold and hardy, dwarves are known as skilled warriors, miners, and workers of stone and metal.', 'Medium', 25, 60, 'PHB'),
('elf', 'Elf', 'Elves are a magical people of otherworldly grace, living in the world but not entirely part of it.', 'Medium', 30, 60, 'PHB'),
('halfling', 'Halfling', 'The diminutive halflings survive in a world full of larger creatures by avoiding notice or, barring that, avoiding offense.', 'Small', 25, 0, 'PHB'),
('human', 'Human', 'Humans are the most adaptable and ambitious people among the common races.', 'Medium', 30, 0, 'PHB'),
('dragonborn', 'Dragonborn', 'Dragonborn are bipedal humanoids with draconic features, born of dragons and proud of their heritage.', 'Medium', 30, 0, 'PHB'),
('gnome', 'Gnome', 'Gnomes are small, clever, and energetic tinkerers who love inventions, exploration, and scholarship.', 'Small', 25, 60, 'PHB'),
('half_elf', 'Half-Elf', 'Half-elves combine the features of elves and humans, often caught between two worlds.', 'Medium', 30, 60, 'PHB'),
('half_orc', 'Half-Orc', 'Half-orcs combine the human capacity for civilization with orcish ferocity and strength.', 'Medium', 30, 60, 'PHB'),
('tiefling', 'Tiefling', 'Tieflings are descended from fiends, bearing infernal heritage that grants them innate magical abilities.', 'Medium', 30, 60, 'PHB');

-- Racial Ability Score Bonuses
INSERT OR IGNORE INTO race_ability_bonuses (race_id, ability, bonus) VALUES
('dwarf', 'CON', 2),
('elf', 'DEX', 2),
('halfling', 'DEX', 2),
('human', 'STR', 1),
('human', 'DEX', 1),
('human', 'CON', 1),
('human', 'INT', 1),
('human', 'WIS', 1),
('human', 'CHA', 1),
('dragonborn', 'STR', 2),
('dragonborn', 'CHA', 1),
('gnome', 'INT', 2),
('half_elf', 'CHA', 2),
('half_orc', 'STR', 2),
('half_orc', 'CON', 1),
('tiefling', 'INT', 1),
('tiefling', 'CHA', 2);

-- Subraces
INSERT OR IGNORE INTO subraces (id, name, race_id, description) VALUES
('hill_dwarf', 'Hill Dwarf', 'dwarf', 'Hill dwarves are hardy and resilient, with a keen wisdom passed down through generations.'),
('mountain_dwarf', 'Mountain Dwarf', 'dwarf', 'Mountain dwarves are strong and sturdy, skilled in combat and metalworking.'),
('high_elf', 'High Elf', 'elf', 'High elves are the most magical of the elves, with a natural affinity for arcane arts.'),
('wood_elf', 'Wood Elf', 'elf', 'Wood elves are swift and stealthy, at home in the forests and attuned to nature.'),
('dark_elf_drow', 'Dark Elf (Drow)', 'elf', 'Drow are dark-skinned elves who dwell in the Underdark, feared for their cruelty and magic.'),
('lightfoot', 'Lightfoot', 'halfling', 'Lightfoot halflings are naturally stealthy and can easily hide from notice.'),
('stout', 'Stout', 'halfling', 'Stout halflings are hardier than their kin, with resistance to poison.'),
('forest_gnome', 'Forest Gnome', 'gnome', 'Forest gnomes are small and reclusive, with a natural talent for illusion magic.'),
('rock_gnome', 'Rock Gnome', 'gnome', 'Rock gnomes are ingenious inventors and tinkerers, master craftspeople of small devices.');

-- (Subrace-specific ability bonuses are handled through the base race + subrace selection at the application level)

-- ============================================================
-- MISSING CLASSES (Bard, Cleric, Monk, Paladin, Ranger, Sorcerer, Warlock, Wizard)
-- ============================================================
INSERT OR IGNORE INTO classes (id, name, hit_die, primary_ability, saving_throw_1, saving_throw_2, description, skill_picks) VALUES
('bard', 'Bard', 'd8', 'CHA', 'DEX', 'CHA', 'Bards are master storytellers, musicians, and magicians who weave magic through words and music.', 3),
('cleric', 'Cleric', 'd8', 'WIS', 'WIS', 'CHA', 'Clerics are divine servants who channel the power of their gods to heal the wounded and smite the wicked.', 2),
('monk', 'Monk', 'd8', 'DEX or WIS', 'STR', 'DEX', 'Monks are masters of martial arts, channeling their inner energy (ki) to achieve supernatural feats.', 2),
('paladin', 'Paladin', 'd10', 'STR or CHA', 'WIS', 'CHA', 'Paladins are holy warriors sworn to uphold justice, righteousness, and their sacred oaths.', 2),
('ranger', 'Ranger', 'd10', 'DEX or WIS', 'STR', 'DEX', 'Rangers are skilled hunters and trackers, at home in the wild and attuned to nature.', 3),
('sorcerer', 'Sorcerer', 'd6', 'CHA', 'CON', 'CHA', 'Sorcerers carry innate magical power, channeling raw arcane energy through their bloodline.', 2),
('warlock', 'Warlock', 'd8', 'CHA', 'WIS', 'CHA', 'Warlocks forge pacts with otherworldly patrons, granting them eldritch powers.', 2),
('wizard', 'Wizard', 'd6', 'INT', 'INT', 'WIS', 'Wizards are scholarly magic-users who study arcane texts and master the weave of magic.', 2);

-- ============================================================
-- SUBCLASSES FOR ROGUE
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('rogue_thief', 'rogue', 'Thief', 'You hone your skills in the larcenous arts, becoming a master of stealth and theft.'),
('rogue_assassin', 'rogue', 'Assassin', 'You focus on the dark arts of death, using stealth, poison, and deadly precision to eliminate targets.'),
('rogue_arcane_trickster', 'rogue', 'Arcane Trickster', 'You weave illusion and enchantment magic into your roguish talents, becoming a magical trickster.'),
('rogue_inquisitive', 'rogue', 'Inquisitive', 'You are a master of observation and deduction, able to read people and situations with uncanny accuracy.'),
('rogue_mastermind', 'rogue', 'Mastermind', 'You are a brilliant strategist and manipulator, able to coordinate allies and read enemies from afar.'),
('rogue_scout', 'rogue', 'Scout', 'You are trained as a wilderness scout, skilled at skirmishing and survival in the wild.'),
('rogue_swashbuckler', 'rogue', 'Swashbuckler', 'You are a daring duelist and acrobat, fighting with flair and panache.'),
('rogue_soulknife', 'rogue', 'Soulknife', 'You manifest psychic blades and other psionic abilities, striking with the power of your mind.'),
('rogue_phantom', 'rogue', 'Phantom', 'You walk the line between life and death, channeling the power of spirits.');

-- ============================================================
-- SUBCLASSES FOR BARD
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('bard_lore', 'bard', 'College of Lore', 'You collect knowledge and stories from across the world, becoming a master of myriad talents.'),
('bard_valor', 'bard', 'College of Valor', 'You inspire courage in others, blending martial combat with bardic performance.'),
('bard_whispers', 'bard', 'College of Whispers', 'You use your art to manipulate and sow fear, weaving dark secrets into your performances.'),
('bard_swords', 'bard', 'College of Swords', 'You perform blade dances that are both deadly and beautiful, fighting with theatrical flair.'),
('bard_glamour', 'bard', 'College of Glamour', 'You weave enchantment and beguilement into your art, captivating audiences and foes alike.'),
('bard_creation', 'bard', 'College of Creation', 'You channel the Song of Creation to weave life into inanimate objects and inspire artistic mastery.'),
('bard_eloquence', 'bard', 'College of Eloquence', 'You are a master of oratory, able to persuade and deceive with unparalleled skill.');

-- ============================================================
-- SUBCLASSES FOR CLERIC
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('cleric_life', 'cleric', 'Life Domain', 'You are a channel of divine life energy, able to heal the wounded and protect the weak.'),
('cleric_light', 'cleric', 'Light Domain', 'You wield the purifying power of light, burning away darkness and evil.'),
('cleric_trickery', 'cleric', 'Trickery Domain', 'You serve a god of deception and illusion, using stealth and guile to further your deity''s aims.'),
('cleric_war', 'cleric', 'War Domain', 'You are a holy crusader, blessed with martial prowess and the power to inspire armies.'),
('cleric_nature', 'cleric', 'Nature Domain', 'You draw power from the natural world, commanding beasts and plants to do your bidding.'),
('cleric_tempest', 'cleric', 'Tempest Domain', 'You channel the fury of the storm, unleashing thunder and lightning upon your enemies.'),
('cleric_knowledge', 'cleric', 'Knowledge Domain', 'You serve a god of knowledge and learning, seeking ancient wisdom and forgotten lore.');

-- ============================================================
-- SUBCLASSES FOR MONK
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('monk_open_hand', 'monk', 'Way of the Open Hand', 'You master the true art of unarmed combat, channeling ki to achieve devastating techniques.'),
('monk_shadow', 'monk', 'Way of Shadow', 'You draw power from the shadows, becoming a master of stealth and darkness.'),
('monk_four_elements', 'monk', 'Way of the Four Elements', 'You harness the power of the elements, bending fire, water, earth, and air to your will.'),
('monk_sun_soul', 'monk', 'Way of the Sun Soul', 'You channel your ki into radiant energy, unleashing bolts of light in combat.'),
('monk_drunken', 'monk', 'Way of the Drunken Master', 'You emulate the unpredictable movements of a drunken brawler, confusing and outmaneuvering foes.'),
('monk_kensei', 'monk', 'Way of the Kensei', 'You channel ki through your weapons, mastering a specific set of weapons as an extension of your body.'),
('monk_mercy', 'monk', 'Way of Mercy', 'You walk a path of healing and harm, using your ki to mend wounds or deliver lethal strikes.');

-- ============================================================
-- SUBCLASSES FOR PALADIN
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('paladin_devotion', 'paladin', 'Oath of Devotion', 'You have sworn an oath to uphold justice and righteousness, standing as a beacon of hope.'),
('paladin_ancients', 'paladin', 'Oath of the Ancients', 'You have sworn an oath to protect the light and beauty of the world, standing against darkness.'),
('paladin_vengeance', 'paladin', 'Oath of Vengeance', 'You have sworn an oath to punish evil, hunting down and destroying those who have done great wrong.'),
('paladin_crown', 'paladin', 'Oath of the Crown', 'You have sworn an oath to serve a nation or sovereign, upholding law and order.'),
('paladin_conquest', 'paladin', 'Oath of Conquest', 'You have sworn an oath to dominate and subjugate, crushing all who stand against your righteous rule.'),
('paladin_redemption', 'paladin', 'Oath of Redemption', 'You have sworn an oath to offer redemption to those who have strayed, believing all can be saved.'),
('paladin_watchers', 'paladin', 'Oath of the Watchers', 'You have sworn an oath to guard the mortal realm against extraplanar threats.');

-- ============================================================
-- SUBCLASSES FOR RANGER
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('ranger_hunter', 'ranger', 'Hunter', 'You are a dedicated hunter of supernatural threats, specializing in tracking and destroying specific prey.'),
('ranger_beast_master', 'ranger', 'Beast Master', 'You form a deep bond with a beast companion, fighting alongside a loyal animal.'),
('ranger_gloom_stalker', 'ranger', 'Gloom Stalker', 'You are a master of hunting in darkness, striking from the shadows with deadly precision.'),
('ranger_horizon_walker', 'ranger', 'Horizon Walker', 'You guard the boundaries between planes, using dimensional magic to hunt threats across worlds.'),
('ranger_fey_wanderer', 'ranger', 'Fey Wanderer', 'You channel the wild magic of the Feywild, imbuing your attacks with beguiling and confusing energy.'),
('ranger_swarm_keeper', 'ranger', 'Swarm Keeper', 'You command a swarm of nature spirits that aid you in battle and exploration.');

-- ============================================================
-- SUBCLASSES FOR SORCERER
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('sorcerer_draconic', 'sorcerer', 'Draconic Bloodline', 'Your innate magic comes from draconic ancestry, manifesting in scales and elemental breath.'),
('sorcerer_wild_magic', 'sorcerer', 'Wild Magic', 'Your magic is raw, chaotic, and unpredictable, drawn from the primal forces of creation.'),
('sorcerer_shadow', 'sorcerer', 'Shadow Magic', 'Your innate magic stems from the Shadowfell, granting you power over darkness and shadows.'),
('sorcerer_storm', 'sorcerer', 'Storm Sorcery', 'Your magic is infused with the power of storms, allowing you to call lightning and control winds.'),
('sorcerer_aberrant', 'sorcerer', 'Aberrant Mind', 'An alien influence has touched your mind, granting you psionic-like abilities and strange powers.'),
('sorcerer_clockwork', 'sorcerer', 'Clockwork Soul', 'Your magic is drawn from the lawful plane of Mechanus, giving you powers of order and precision.');

-- ============================================================
-- SUBCLASSES FOR WARLOCK
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('warlock_fiend', 'warlock', 'The Fiend', 'You have made a pact with a fiend from the lower planes, gaining infernal powers.'),
('warlock_archfey', 'warlock', 'The Archfey', 'You have made a pact with a powerful fey lord, gaining beguiling and enchanting magic.'),
('warlock_great_old_one', 'warlock', 'The Great Old One', 'You have made a pact with an ancient, alien entity from beyond the stars.'),
('warlock_hexblade', 'warlock', 'The Hexblade', 'You have made a pact with a mysterious entity from the Shadowfell that manifests as a sentient weapon.'),
('warlock_celestial', 'warlock', 'The Celestial', 'You have made a pact with a powerful celestial being, gaining healing and radiant powers.'),
('warlock_genie', 'warlock', 'The Genie', 'You have made a pact with a mighty genie, gaining elemental powers and a magical vessel.');

-- ============================================================
-- SUBCLASSES FOR WIZARD
-- ============================================================
INSERT OR IGNORE INTO subclasses (id, class_id, name, description) VALUES
('wizard_abjuration', 'wizard', 'School of Abjuration', 'You specialize in protective magic, creating wards and barriers against harm.'),
('wizard_conjuration', 'wizard', 'School of Conjuration', 'You specialize in summoning creatures and objects from other planes of existence.'),
('wizard_divination', 'wizard', 'School of Divination', 'You specialize in magic that reveals knowledge, glimpses the future, and uncovers hidden truths.'),
('wizard_enchantment', 'wizard', 'School of Enchantment', 'You specialize in magic that beguiles and influences the minds of others.'),
('wizard_evocation', 'wizard', 'School of Evocation', 'You specialize in elemental and destructive magic, shaping raw energy into devastating effects.'),
('wizard_illusion', 'wizard', 'School of Illusion', 'You specialize in magic that deceives the senses, crafting convincing false realities.'),
('wizard_necromancy', 'wizard', 'School of Necromancy', 'You specialize in magic that manipulates the forces of life and death.'),
('wizard_transmutation', 'wizard', 'School of Transmutation', 'You specialize in magic that transforms objects, creatures, and reality itself.');

-- ============================================================
-- BACKGROUNDS
-- ============================================================
INSERT OR IGNORE INTO backgrounds (id, name, description, skill_proficiencies, tool_proficiencies, feature_name, feature_description, source) VALUES
('acolyte', 'Acolyte', 'You have spent your life in service to a temple, learning sacred rites and providing spiritual guidance.', '["ins","rel"]', NULL, 'Shelter of the Faithful', 'As an acolyte, you command the respect of those who share your faith, and you can perform the religious ceremonies of your deity. You and your adventuring companions can expect to receive free healing and care at a temple, shrine, or other established presence of your faith.', 'PHB'),

('charlatan', 'Charlatan', 'You are a master of deception and trickery, skilled at creating false identities and fleecing the unwary.', '["dec","slh"]', '["disguise_kit","forgery_kit"]', 'False Identity', 'You have created a second identity that includes documentation, established acquaintances, and disguises that allow you to assume that persona. Additionally, you can forge documents including official papers and personal letters.', 'PHB'),

('criminal', 'Criminal / Spy', 'You have a history of breaking the law, whether as a thief, smuggler, spy, or other shady profession.', '["dec","ste"]', '["thieves_tools","gaming_set"]', 'Criminal Contact', 'You have a reliable and trustworthy contact who acts as your liaison to a network of other criminals. You know how to get messages to and from your contact, even over great distances.', 'PHB'),

('entertainer', 'Entertainer', 'You thrive in front of an audience, whether as a musician, dancer, storyteller, or actor.', '["acr","prf"]', '["disguise_kit","musical_instrument"]', 'By Popular Demand', 'You can always find a place to perform, usually in an inn or tavern but possibly with a circus, theater, or even a noble''s court. At such a place, you receive free lodging and food of a modest or comfortable standard.', 'PHB'),

('folk_hero', 'Folk Hero', 'You rose from humble beginnings to become a champion of the common people.', '["ani","sur"]', '["vehicles_land","artisans_tools"]', 'Rustic Hospitality', 'Since you come from the ranks of the common folk, you fit in among them with ease. You can find a place to hide, rest, or recuperate among other commoners, who will shield you from the law or anyone else searching for you.', 'PHB'),

('guild_artisan', 'Guild Artisan', 'You are a skilled artisan and member of a trade guild, valuing craftsmanship and commerce.', '["ins","prs"]', '["artisans_tools"]', 'Guild Membership', 'As an established and respected member of a guild, you can rely on certain benefits from your membership. Your fellow guild members will provide you with lodging and food if necessary, and pay for your funeral if needed.', 'PHB'),

('hermit', 'Hermit', 'You lived a secluded life in isolation, whether for religious contemplation or to escape society.', '["med","rel"]', '["herbalism_kit"]', 'Discovery', 'The quiet seclusion of your extended hermitage gave you access to a unique and powerful discovery.', 'PHB'),

('noble', 'Noble', 'You were born into wealth and privilege, carrying the weight of your family name.', '["his","prs"]', '["gaming_set","musical_instrument"]', 'Position of Privilege', 'Thanks to your noble birth, people are inclined to think the best of you. You are welcome in high society, and people with influence will go out of their way to help you.', 'PHB'),

('outlander', 'Outlander', 'You grew up in the wilds, far from civilization and its comforts.', '["ath","sur"]', '["musical_instrument","vehicles_land"]', 'Wanderer', 'You have an excellent memory for maps and geography, and you can always recall the general layout of terrain, settlements, and other features around you.', 'PHB'),

('sage', 'Sage', 'You are a scholar and seeker of knowledge, spending years studying in libraries and universities.', '["arc","his"]', NULL, 'Researcher', 'When you attempt to learn or recall a piece of lore, if you do not know that information, you often know where and from whom you can obtain it.', 'PHB'),

('sailor', 'Sailor', 'You spent years at sea, learning the ways of ships and the dangers of the deep.', '["ath","prc"]', '["vehicles_water","navigators_tools"]', 'Ship''s Passage', 'When you need to, you can secure free passage on a sailing ship for yourself and your adventuring companions.', 'PHB'),

('soldier', 'Soldier', 'You served in an army, learning the discipline and tactics of military life.', '["ath","int"]', '["gaming_set","vehicles_land"]', 'Military Rank', 'Your military rank gives you a claim to the loyalty of other soldiers. You can exert influence over soldiers and gain access to military facilities.', 'PHB'),

('urchin', 'Urchin', 'You grew up on the streets of a major city, surviving by your wits and quick hands.', '["slh","ste"]', '["thieves_tools","disguise_kit"]', 'City Secrets', 'You know the secret patterns and flow to cities and can find passages through the urban sprawl that others would miss.', 'PHB');
