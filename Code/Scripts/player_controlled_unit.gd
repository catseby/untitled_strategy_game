extends Node3D

@export var move_range : int = 5

signal show_indicators(unit)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	show_indicators.emit(self)
