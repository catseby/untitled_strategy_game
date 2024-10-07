extends Node3D

@onready var status = $onfield_unit_status
@onready var skills = $Skills

@export var move_range : int = 7

@export var max_action_points : int = 2 
var action_points = max_action_points

var turn_order : int = 100

signal await_command(unit)
signal action_fufilled
signal next

var path : Array[Vector3] = []

var state = IDLE
enum {
	IDLE,
	MOVING
}

func _ready() -> void:
	$onfield_unit_status/SubViewport/Label2.text = name

func act():
	await get_tree().create_timer(1).timeout
	await_command.emit(self)

func move(new_path):
	action_points -= 1
	status.set_action_points(action_points)
	path = new_path
	state = MOVING

func rest():
	var pr : float = (1.0 / max_action_points) * 100
	turn_order = action_points * pr + pr
	
	action_points = max_action_points
	status.set_action_points(action_points)
	next.emit()

var time = 0.0

func _physics_process(delta: float) -> void:
	if state == MOVING:
		time += delta
		if time >= 0.2:
			global_position = path.pop_front()
			time = 0
			if path.is_empty():
				state = IDLE
				await_command.emit(self)

func hit(attack):
	print(attack.damage)
