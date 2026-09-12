extends SceneTree

const SAVE_PATH := "user://audio-director-test.json"
var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://audio/manifest.json"))
	for audio_id in manifest.sfx:
		_expect(FileAccess.file_exists("res://audio/" + manifest.sfx[audio_id]), "SFX asset resolves: " + audio_id)
	for music_id in manifest.music:
		_expect(FileAccess.file_exists("res://audio/" + manifest.music[music_id]), "music asset resolves: " + music_id)

	var director := AudioDirector.new()
	var fired: Array[StringName] = []
	director.event_fired.connect(func(audio_id: StringName): fired.append(audio_id))
	for audio_id in AudioDirector.SFX_IDS:
		_expect(director.emit_event(audio_id), "event id is accepted: " + str(audio_id))
	_expect(fired.size() == 6 and fired == AudioDirector.SFX_IDS, "six SFX events fire exactly once")

	var crossfade: Array[StringName] = []
	director.music_crossfade.connect(func(from_id: StringName, to_id: StringName): crossfade.append(from_id); crossfade.append(to_id))
	director.begin_boss_crossfade()
	director.begin_boss_crossfade()
	_expect(crossfade == [&"environment_loop", &"boss_loop"], "boss crossfade occurs once at the tell")

	_cleanup()
	var save := SaveSystem.new(SAVE_PATH)
	var data := save.defaults()
	_expect(save.save(data).ok, "audio settings fixture save succeeds")
	director.set_volume(&"master", 0.0)
	director.set_volume(&"music", 0.35)
	_expect(director.save_settings(save).ok, "audio settings save succeeds")
	var reloaded := AudioDirector.new()
	reloaded.load_settings(save)
	_expect(reloaded.volumes.master == 0.0, "zero master volume persists as muted")
	_expect(is_equal_approx(reloaded.volumes.music, 0.35), "music volume persists across reload")
	_cleanup()

	if failures.is_empty():
		print("AudioDirector tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _cleanup() -> void:
	for path in [SAVE_PATH, SAVE_PATH + ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
