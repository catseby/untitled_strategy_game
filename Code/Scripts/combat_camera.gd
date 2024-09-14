extends CharacterBody3D

@onready var camera = $Camera3D

@export var speed : float = 10.0
@export var acceleration : float = 5.0
@export var zoom_min : float = 2.0
@export var zoom_max : float = 20.0
@export var zoom_speed : float = 4
@export var zoom_acceleration : float = 2
@export var zoom_deacceleration : float = 20
var zoom_time = 0.0
var zoom_velocity : float = 0.0

@export var rotate_speed : float = 5
@export var rotate_acceleration : float = 1
@export var rotate_deacceleration : float = 10
var rotate_velocity : float = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var input = Vector2.ZERO
	input.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	input.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input = input.normalized()
	
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var relativeDir = (forward * input.y + right * input.x)
	
	velocity = velocity.lerp(relativeDir * speed, acceleration * delta)
	
	move_and_slide()
	
	var zoom = int(Input.is_action_just_pressed("zoom_out")) - int(Input.is_action_just_pressed("zoom_in"))
	
	if Input.is_action_pressed("zoom_in") or Input.is_action_pressed("zoom_out"):
		zoom = float(Input.is_action_pressed("zoom_out")) - float(Input.is_action_pressed("zoom_in"))
		zoom = zoom / 6
	
	
	if zoom != 0:
		zoom_velocity = lerpf(zoom_velocity,zoom * zoom_speed, zoom_acceleration * delta)
	else:
		zoom_velocity = lerpf(zoom_velocity,0, zoom_deacceleration * delta)
	
	camera.size += zoom_velocity
	camera.size = clampf(camera.size,zoom_min,zoom_max)
	
	
	var rotate_input = int(Input.is_action_pressed("rotate_right")) - int(Input.is_action_pressed("rotate_left"))
	
	if rotate_input != 0:
		rotate_velocity = lerpf(rotate_velocity, rotate_input * rotate_speed , rotate_acceleration * delta)
	else:
		rotate_velocity = lerpf(rotate_velocity, 0, rotate_deacceleration * delta)

	
	rotation_degrees.y += rotate_velocity
