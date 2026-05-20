use crate::models::{EncounterData, SavedStateData};
use std::fs;
use std::path::PathBuf;
use tauri::AppHandle;
use tauri::Manager;

fn encounters_dir(app: &AppHandle) -> Result<PathBuf, String> {
    let mut dir = app.path().app_data_dir().map_err(|e| e.to_string())?;
    dir.push("encounters");
    fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
    Ok(dir)
}

#[tauri::command]
pub fn save_encounter(app: AppHandle, data: EncounterData) -> Result<(), String> {
    let dir = encounters_dir(&app)?;
    let mut file_path = dir;
    file_path.push(format!("{}.json", data.id));
    let json = serde_json::to_string_pretty(&data).map_err(|e| e.to_string())?;
    fs::write(&file_path, json).map_err(|e| e.to_string())?;
    Ok(())
}

#[tauri::command]
pub fn load_encounters(app: AppHandle) -> Result<Vec<EncounterData>, String> {
    let dir = encounters_dir(&app)?;
    let mut encounters = Vec::new();
    if !dir.exists() {
        return Ok(encounters);
    }
    for entry in fs::read_dir(&dir).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) == Some("json") {
            let content = fs::read_to_string(&path).map_err(|e| e.to_string())?;
            let data: EncounterData = serde_json::from_str(&content).map_err(|e| e.to_string())?;
            encounters.push(data);
        }
    }
    encounters.sort_by(|a, b| a.name.cmp(&b.name));
    Ok(encounters)
}

#[tauri::command]
pub fn delete_encounter(app: AppHandle, id: String) -> Result<(), String> {
    let dir = encounters_dir(&app)?;
    let mut file_path = dir;
    file_path.push(format!("{}.json", id));
    if file_path.exists() {
        fs::remove_file(&file_path).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn sessions_dir(app: &AppHandle) -> Result<PathBuf, String> {
    let mut dir = app.path().app_data_dir().map_err(|e| e.to_string())?;
    dir.push("sessions");
    fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
    Ok(dir)
}

#[tauri::command]
pub fn save_state(app: AppHandle, data: SavedStateData) -> Result<(), String> {
    let dir = sessions_dir(&app)?;
    let mut file_path = dir;
    file_path.push(format!("{}.json", data.id));
    let json = serde_json::to_string_pretty(&data).map_err(|e| e.to_string())?;
    fs::write(&file_path, json).map_err(|e| e.to_string())?;
    Ok(())
}

#[tauri::command]
pub fn load_states(app: AppHandle) -> Result<Vec<SavedStateData>, String> {
    let dir = sessions_dir(&app)?;
    let mut states = Vec::new();
    if !dir.exists() {
        return Ok(states);
    }
    for entry in fs::read_dir(&dir).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) == Some("json") {
            let content = fs::read_to_string(&path).map_err(|e| e.to_string())?;
            let data: SavedStateData = serde_json::from_str(&content).map_err(|e| e.to_string())?;
            states.push(data);
        }
    }
    states.sort_by(|a, b| b.saved_at.cmp(&a.saved_at));
    Ok(states)
}

#[tauri::command]
pub fn load_state(app: AppHandle, id: String) -> Result<SavedStateData, String> {
    let dir = sessions_dir(&app)?;
    let mut file_path = dir;
    file_path.push(format!("{}.json", id));
    let content = fs::read_to_string(&file_path).map_err(|e| e.to_string())?;
    let data: SavedStateData = serde_json::from_str(&content).map_err(|e| e.to_string())?;
    Ok(data)
}

#[tauri::command]
pub fn delete_state(app: AppHandle, id: String) -> Result<(), String> {
    let dir = sessions_dir(&app)?;
    let mut file_path = dir;
    file_path.push(format!("{}.json", id));
    if file_path.exists() {
        fs::remove_file(&file_path).map_err(|e| e.to_string())?;
    }
    Ok(())
}
