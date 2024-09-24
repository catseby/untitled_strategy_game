extends Node3D

@onready var status = $onfield_unit_status

@export var move_range : int = 7

@export var max_action_points : int = 2 
var action_points = max_action_points

var turn_order : int = 100

signal await_command(unit)
signal action_fufilled
signal next

func _ready() -> void:
	$onfield_unit_status/SubViewport/Label2.text = name

func act():
	await get_tree().create_timer(1).timeout
	await_command.emit(self)

func move(new_position):
	action_points -= 1
	status.set_action_points(action_points)
	global_position = new_position
	await get_tree().create_timer(1).timeout
	await_command.emit(self)

func rest():
	var pr : float = (1.0 / max_action_points) * 100
	turn_order = action_points * pr + pr
	
	action_points = max_action_points
	status.set_action_points(action_points)
	next.emit()
