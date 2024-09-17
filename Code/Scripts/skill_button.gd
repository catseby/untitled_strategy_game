extends Button

var type = 0

signal was_pressed(button : Button)


func _on_pressed() -> void:
	was_pressed.emit(self)
