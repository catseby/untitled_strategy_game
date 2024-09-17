extends Node3D

@export var move_range : int = 4

signal await_command(unit)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	await_command.emit(self)

func move(new_position):
	global_position = new_position
	await get_tree().create_timer(1).timeout
	await_command.emit(self)
