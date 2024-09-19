extends Button


@export var required_action_points : int = 1
@export var key = KEY_0
var skill : Node

var active = true
signal was_pressed(button : Button)

func check_required_ap(cap):
	if cap < required_action_points:
		active = false
		modulate.a = 0.75

func _on_pressed() -> void:
	if active:
		was_pressed.emit(self)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and active:
		if event.is_pressed() and not event.is_echo():
			if event.keycode == key:
					was_pressed.emit(self)
