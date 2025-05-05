extends Node3D
class_name HitIndicator

var p_label : Label3D
var s_label : Label3D

const PRIMARY_ALPHA : float = 0.8
const SECONDARY_ALPHA : float = 0.3

var offset_amount : float = 2.0
var offset_speed : float = 0.5

func _setup(origin) -> void:
	global_position = origin
	
	var x : float = randf_range(-1,1)
	var z : float = randf_range(-1,1)
	
	p_label = get_node("Pivot/PrimaryLabel")
	s_label = get_node("Pivot/SecondaryLabel")
	
	p_label.position.x = x
	s_label.position.x = x
	p_label.position.z = z
	s_label.position.z = z

var time : float = 0.0

func _physics_process(delta: float) -> void:
	time -= delta
	if time <= 0.0:
		var x = randf_range(-offset_amount, offset_amount)
		var y = randf_range(-offset_amount, offset_amount)
		s_label.offset = Vector2(x,y)
		time = offset_speed
