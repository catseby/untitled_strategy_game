extends Node3D


#----------------------------------------------------------------------------
#------------------------------@ONREADY_NODES-----------------------------------

@onready var status = $onfield_unit_status/Unit_Hover_UI/Unit_Hover_UI
@onready var skills = $Skills
@onready var anim = $AnimationPlayer



#-----------------------------------------------------------------------------
#---------------------------------UNIQUE VARIABLES----------------------------

var first_name : String = "Unkown"
var last_name : String = ""

var group : String

@export var move_range : int = 4
@export var visibility_range : int = 15

@export var max_hit_points : int = 2
@onready var hit_points = max_hit_points

@export var max_action_points : int = 2
@onready var action_points = max_action_points

var turn_order : int = 100


#-----------------------------------------------------------------
#--------------------------SIGNALS--------------------------------

signal await_command(unit)
signal action_fufilled
signal next


#------------------------------------------------------------------
#----------------------------VARIABLES-----------------------------

var path : Array[Vector3] = []

var state = IDLE
enum {
	IDLE,
	MOVING
}

func _ready() -> void:
	status.update(self)
	

func act():
	await get_tree().create_timer(1).timeout
	await_command.emit(self)

func move(new_path):
	action_points -= 1
	status.update(self)
	path = new_path
	state = MOVING

func skill():
	action_points -= 1
	status.update(self)
	anim.play("attack")
	await anim.animation_finished
	act()


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
				act()

func hit(attack):
	hit_points -= attack.damage
	$AnimationPlayer.play("hit")
	await $AnimationPlayer.animation_finished
	status.update(self)
	if hit_points <= 0:
		remove_from_group(group)
		queue_free()
