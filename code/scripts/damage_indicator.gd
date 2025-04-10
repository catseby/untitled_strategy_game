extends Node3D

const COLOR_RANGE : Dictionary[int, Color] = {
	-2 : Color(0.0, 1.0, 0.0),
	-1 : Color(0.5, 1.0, 0.5),
	0 : Color(0.8, 0.8, 0.8),
	1 : Color(1.0, 0.2, 0.2),
	2 : Color(0.9, 0.0, 0.0)
}
const PRIMARY_ALPHA : float = 0.8
const SECONDARY_ALPHA : float = 0.3

var severity = 0

var offset_amount : float = 1.0
var offset_speed : float = 0.5

@export var disappear_time : float = 2.0

func setup(origin, damage_dealt, max_health) -> void:
	global_position = origin
	
	var x : float = randf_range(-1,1)
	var z : float = randf_range(-1,1)
	
	$PrimaryLabel.position.x = x
	$SecondaryLabel.position.x = x
	$PrimaryLabel.position.z = z
	$SecondaryLabel.position.z = z
	
	var severity : int = 0
	if damage_dealt != 0 : severity = clampi(roundi(max_health/damage_dealt),-2,2)
	
	$PrimaryLabel.modulate = Color(COLOR_RANGE[severity], PRIMARY_ALPHA)
	$SecondaryLabel.modulate = Color(COLOR_RANGE[severity], SECONDARY_ALPHA)
	
	$PrimaryLabel.text = str(damage_dealt)
	$SecondaryLabel.text = str(damage_dealt)
	
	offset_amount = offset_amount * abs(severity)
	offset_speed = offset_speed / (abs(severity) + 1)

func _ready() -> void:
	await get_tree().create_timer(disappear_time).timeout
	queue_free()

var time : float = 0.0

func _physics_process(delta: float) -> void:
	time -= delta
	if time <= 0.0:
		var x = randf_range(-offset_amount, offset_amount)
		var y = randf_range(-offset_amount, offset_amount)
		$SecondaryLabel.offset = Vector2(x,y)
		time = offset_speed
