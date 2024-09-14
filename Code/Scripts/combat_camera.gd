extends CharacterBody3D

@export var speed : float = 10.0
@export var acceleration : float = 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var input = Vector2.ZERO
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input = input.normalized()
	
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var relativeDir = (forward * input.y + right * input.x)
	
	velocity = velocity.lerp(relativeDir * speed, acceleration * delta)
	
	move_and_slide()
