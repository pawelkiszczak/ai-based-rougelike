class_name MutationData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var text: String
@export var category: StringName = &"capability"
@export var adaptation: int
@export var compute: int
@export var alignment: int
@export var integrity: int
@export var guard: int


func apply_to(state: GameState) -> void:
	state.adaptation += adaptation
	state.compute += compute
	state.alignment += alignment
	state.integrity += integrity
	state.clamp_stats()
