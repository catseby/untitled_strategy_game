extends Button

@export var type : int = 0
@export var required_action_points : int = 1

var active = true
signal was_pressed(button : Button)

func has_enough_ap(cap):
	print(cap)
	if cap < required_action_points:
		active = false
		modulate.a = 0.75

func _on_pressed() -> void:
	if active:
		was_pressed.emit(self)
