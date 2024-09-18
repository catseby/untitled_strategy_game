extends Node3D

@onready var status = $onfield_unit_status

@export var move_range : int = 7

@export var max_action_points : int = 2 
var action_points = max_action_points

signal await_command(unit)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	await_command.emit(self)

func move(new_position):
	action_points -= 1
	status.set_action_points(action_points)
	global_position = new_position
	await get_tree().create_timer(1).timeout
	await_command.emit(self)
