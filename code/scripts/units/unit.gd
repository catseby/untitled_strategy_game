extends Node3D
class_name Unit
## Basic controllable unit, which can be controlled using a controller.

#----------------------------------------------------------------------------
#------------------------------@ONREADY_NODES-----------------------------------

@onready var status = $onfield_unit_status/Unit_Hover_UI/Unit_Hover_UI
@onready var skills = $Skills
@onready var anim = $AnimationPlayer

#-----------------------------------------------------------------------------
#---------------------------------UNIQUE VARIABLES----------------------------

var first_name : String = "Unkown"
var last_name : String = ""
@onready var full_name : String = first_name + " " + last_name

var group : String ## Units group (Controller)

@export var move_range : int = 4 ## How far the unit can move.
@export var visibility_range : int = 8 ## How far the unit can see.

@export var max_hit_points : int = 2 ## Hit points (Health).
@onready var hit_points = max_hit_points ## Current hit points (Health).

@export var max_action_points : int = 2 ## How many actions the unit can perform.
@onready var action_points = max_action_points ## Current remaining action points.

var turn_order : int = 100 ## Current turn score. Higher values guarantee a higher spot in the turn order.

#-----------------------------------------------------------------
#--------------------------SIGNALS--------------------------------

signal await_command(unit) ## Informs the controller that the unit is awaiting a command.
signal moved(unit)
signal next ## Informs the level that the unit has ended their turn.

#------------------------------------------------------------------
#----------------------------VARIABLES-----------------------------

var path : Array[Vector3] = [] ## The path the unit has to traverse in the "MOVE" state.

var state = IDLE ## Units current state.
enum {
	IDLE, ## Unit is idle.
	MOVING ## Unit is moving.
}

func _ready() -> void:
	status.update(self)


## Enables units ability to take action.
func act():
	await get_tree().create_timer(1).timeout
	await_command.emit(self)

## Make unit move along a specific path.
func move(new_path):
	action_points -= 1
	status.update(self)
	path = new_path
	state = MOVING

## Make unit use a skill.
func skill():
	action_points -= 1
	status.update(self)
	anim.play("attack")
	await anim.animation_finished
	act()

## End unit's turn.
func rest():
	var pr : float = (1.0 / max_action_points) * 100
	turn_order = action_points * pr + pr

	action_points = max_action_points
	status.update(self)
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
				moved.emit(self)
				act()

## Deal damage to, attack, the unit.
func hit(attack):
	hit_points -= attack.damage
	hit_points = clampi(hit_points,0,max_hit_points)
	$AnimationPlayer2.play("hit")
	await $AnimationPlayer2.animation_finished
	status.update(self)
	if hit_points <= 0:
		remove_from_group(group)
		queue_free()
