class_name AudioDirector
extends RefCounted

signal event_fired(audio_id: StringName)
signal music_crossfade(from_id: StringName, to_id: StringName)

const DEFAULT_VOLUMES := {"master": 1.0, "sfx": 1.0, "music": 1.0}
const SFX_IDS := [&"choice", &"damage", &"unlock", &"win", &"lose", &"boss_tell"]

var volumes: Dictionary = DEFAULT_VOLUMES.duplicate(true)
var current_music: StringName = &"environment_loop"
var event_history: Array[StringName] = []


func emit_event(audio_id: StringName) -> bool:
	if audio_id not in SFX_IDS:
		return false
	event_history.append(audio_id)
	event_fired.emit(audio_id)
	return true


func begin_boss_crossfade() -> void:
	if current_music == &"boss_loop":
		return
	var previous := current_music
	current_music = &"boss_loop"
	music_crossfade.emit(previous, current_music)


func set_volume(bus: StringName, level: float) -> void:
	if not volumes.has(bus):
		return
	volumes[bus] = clampf(level, 0.0, 1.0)


func save_settings(save_system: SaveSystem) -> Dictionary:
	var next_data: Dictionary = save_system.load().data
	var settings: Dictionary = next_data["settings"]
	settings["audio_volumes"] = volumes.duplicate(true)
	next_data["settings"] = settings
	return save_system.save(next_data)


func load_settings(save_system: SaveSystem) -> void:
	var loaded: Dictionary = save_system.load().data
	var settings: Dictionary = loaded.get("settings", {})
	var saved: Dictionary = settings.get("audio_volumes", {})
	for bus in DEFAULT_VOLUMES:
		if saved.has(bus) and (saved[bus] is int or saved[bus] is float):
			volumes[bus] = clampf(float(saved[bus]), 0.0, 1.0)
