extends SceneTree

const WARMUP_FRAMES := 300
const SAMPLE_FRAMES := 600

var frame_count := 0
var frame_times: Array[float] = []
var peak_memory_bytes := 0


func _init() -> void:
	call_deferred("_start")


func _start() -> void:
	var scene := preload("res://scenes/run.tscn").instantiate()
	get_root().add_child(scene)
	process_frame.connect(_sample_frame)


func _sample_frame() -> void:
	frame_count += 1
	peak_memory_bytes = maxi(peak_memory_bytes, int(Performance.get_monitor(Performance.MEMORY_STATIC)))
	if frame_count > WARMUP_FRAMES:
		frame_times.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	if frame_times.size() < SAMPLE_FRAMES:
		return
	frame_times.sort()
	var p99_index := mini(frame_times.size() - 1, ceili(frame_times.size() * 0.99) - 1)
	print("PERFORMANCE_REPORT " + JSON.stringify({
		"warmup_frames": WARMUP_FRAMES,
		"sample_frames": SAMPLE_FRAMES,
		"p99_frame_ms": frame_times[p99_index],
		"peak_static_memory_bytes": peak_memory_bytes,
		"target_frame_ms": 1000.0 / 60.0,
		"target_memory_bytes": 1024 * 1024 * 1024,
	}))
	quit()
