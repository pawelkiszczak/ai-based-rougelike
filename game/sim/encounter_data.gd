class_name EncounterData
extends Resource

@export var id: StringName
@export var kind: StringName = &"combat"
@export var display_name: String
@export var pressure: int = 0
@export var alignment_requirement: int = 0
@export var outcomes: Array[Dictionary] = []
