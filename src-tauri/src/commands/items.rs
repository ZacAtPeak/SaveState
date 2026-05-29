use crate::db::{queries, DbPool};
use crate::models::{
    EntityActionWithSource, InventoryItemResponse, ItemLibrary, WeaponProfile,
};
use tauri::State;

/// Get all items in the item_library.
#[tauri::command]
pub fn get_item_library(state: State<DbPool>) -> Result<Vec<ItemLibrary>, String> {
    let conn = state.lock()?;
    let mut stmt = conn
        .prepare(queries::GET_ITEM_LIBRARY)
        .map_err(|e| e.to_string())?;

    let items = stmt
        .query_map([], |row| {
            let is_magical: i32 = row.get(7)?;

            Ok(ItemLibrary {
                id: row.get(0)?,
                name: row.get(1)?,
                item_type: row.get(2)?,
                description: row.get(3)?,
                rarity: row.get(4)?,
                weight: row.get(5)?,
                value_gp: row.get(6)?,
                is_magical: is_magical == 1,
                attack_bonus: row.get(8)?,
                damage_bonus: row.get(9)?,
                damage_bonus_type: row.get(10)?,
                source: row.get(11)?,
                page: row.get(12)?,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    Ok(items)
}

/// Get an entity's full inventory (items + optional weapon/armor profiles).
#[tauri::command]
pub fn get_entity_inventory(
    entity_id: String,
    state: State<DbPool>,
) -> Result<Vec<InventoryItemResponse>, String> {
    let conn = state.lock()?;

    let mut stmt = conn
        .prepare(queries::GET_ENTITY_INVENTORY)
        .map_err(|e| e.to_string())?;

    let mut items: Vec<InventoryItemResponse> = stmt
        .query_map([&entity_id], |row| {
            let is_equipped: i32 = row.get(3)?;
            let is_magical: i32 = row.get(13)?;

            Ok(InventoryItemResponse {
                item: ItemLibrary {
                    id: row.get(5)?,
                    name: row.get(6)?,
                    item_type: row.get(7)?,
                    description: row.get(8)?,
                    rarity: row.get(9)?,
                    weight: row.get(10)?,
                    value_gp: row.get(11)?,
                    is_magical: is_magical == 1,
                    attack_bonus: row.get(14)?,
                    damage_bonus: row.get(15)?,
                    damage_bonus_type: row.get(16)?,
                    source: row.get(17)?,
                    page: row.get(18)?,
                },
                weapon_profile: None,
                armor_profile: None,
                quantity: row.get(2)?,
                is_equipped: is_equipped == 1,
                equipped_slot: row.get(4)?,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    // For each item, fetch the weapon profile (if it exists) or armor profile
    for inv_item in &mut items {
        // Try weapon profile
        if let Ok(mut wp_stmt) = conn.prepare(queries::GET_WEAPON_PROFILE) {
            if let Ok(mut rows) = wp_stmt.query_map([&inv_item.item.id], |row| {
                Ok(WeaponProfile {
                    item_id: row.get(0)?,
                    weapon_category: row.get(1)?,
                    weapon_range: row.get(2)?,
                    damage_dice: row.get(3)?,
                    damage_type: row.get(4)?,
                    range_normal: row.get(5)?,
                    range_long: row.get(6)?,
                    versatile_dice: row.get(7)?,
                    properties: row.get(8)?,
                })
            }) {
                if let Some(Ok(wp)) = rows.next() {
                    inv_item.weapon_profile = Some(wp);
                    continue;
                }
            }
        }
    }

    Ok(items)
}

/// Equip an item — sets is_equipped = 1 and assigns an equipment slot.
#[tauri::command]
pub fn equip_item(
    entity_id: String,
    item_id: String,
    equipped_slot: String,
    state: State<DbPool>,
) -> Result<(), String> {
    let conn = state.lock()?;
    conn.execute(
        queries::EQUIP_ITEM,
        [&equipped_slot, &entity_id, &item_id],
    )
    .map_err(|e| e.to_string())?;
    Ok(())
}

/// Unequip an item — sets is_equipped = 0 and clears the slot.
#[tauri::command]
pub fn unequip_item(
    entity_id: String,
    item_id: String,
    state: State<DbPool>,
) -> Result<(), String> {
    let conn = state.lock()?;
    conn.execute(queries::UNEQUIP_ITEM, [&entity_id, &item_id])
        .map_err(|e| e.to_string())?;
    Ok(())
}

/// Get actions for an entity, merging innate actions (entity_actions) with
/// actions from equipped items (item_actions). Returns EntityActionWithSource
/// so the frontend can distinguish between the two.
#[tauri::command]
pub fn get_entity_actions_with_items(
    entity_id: String,
    state: State<DbPool>,
) -> Result<Vec<EntityActionWithSource>, String> {
    let conn = state.lock()?;
    let mut actions: Vec<EntityActionWithSource> = Vec::new();

    // 1. Innate actions from entity_actions
    if let Ok(mut stmt) = conn.prepare(queries::GET_ENTITY_ACTIONS) {
        if let Ok(rows) = stmt.query_map([&entity_id], |row| -> Result<EntityActionWithSource, rusqlite::Error> {
            let is_attack: i32 = row.get(4)?;
            Ok(EntityActionWithSource {
                action_id: row.get(0)?,
                name: row.get(1)?,
                action_type: row.get(2)?,
                description: row.get(3)?,
                is_attack: is_attack == 1,
                attack_bonus: row.get(5)?,
                damage_dice: row.get(6)?,
                damage_type: row.get(7)?,
                uses_per_day: row.get(8)?,
                uses_current: row.get(9)?,
                recharge_formula: row.get(10)?,
                source: "innate".to_string(),
                source_item_name: None,
            })
        }) {
            for row in rows.flatten() {
                actions.push(row);
            }
        }
    }

    // 2. Actions from equipped items
    if let Ok(mut stmt) = conn.prepare(queries::GET_EQUIPPED_ITEM_ACTIONS) {
        if let Ok(rows) = stmt.query_map([&entity_id], |row| -> Result<EntityActionWithSource, rusqlite::Error> {
            let is_attack: i32 = row.get(4)?;
            let item_name: Option<String> = row.get(11)?;
            Ok(EntityActionWithSource {
                action_id: row.get(0)?,
                name: row.get(1)?,
                action_type: row.get(2)?,
                description: row.get(3)?,
                is_attack: is_attack == 1,
                attack_bonus: row.get(5)?,
                damage_dice: row.get(6)?,
                damage_type: row.get(7)?,
                uses_per_day: None,
                uses_current: None,
                recharge_formula: None,
                source: "item".to_string(),
                source_item_name: item_name,
            })
        }) {
            for row in rows.flatten() {
                // Avoid duplicating actions that the entity already has innately
                // (e.g., if a goblin has both entity_actions + scimitar item for the same action)
                if !actions.iter().any(|a| a.action_id == row.action_id) {
                    actions.push(row);
                }
            }
        }
    }

    Ok(actions)
}

/// Add an item to an entity's inventory (upserts quantity).
#[tauri::command]
pub fn add_item_to_entity(
    entity_id: String,
    item_id: String,
    quantity: i32,
    state: State<DbPool>,
) -> Result<(), String> {
    let conn = state.lock()?;
    conn.execute(
        queries::ADD_ITEM_TO_ENTITY,
        [&entity_id, &item_id, &quantity.to_string()],
    )
    .map_err(|e| e.to_string())?;
    Ok(())
}

/// Remove an item from an entity's inventory entirely.
#[tauri::command]
pub fn remove_item_from_entity(
    entity_id: String,
    item_id: String,
    state: State<DbPool>,
) -> Result<(), String> {
    let conn = state.lock()?;
    conn.execute(queries::REMOVE_ITEM_FROM_ENTITY, [&entity_id, &item_id])
        .map_err(|e| e.to_string())?;
    Ok(())
}
