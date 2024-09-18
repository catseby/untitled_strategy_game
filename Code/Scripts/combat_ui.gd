extends Control

const SKILL_BUTTON = preload("res://Level/UI/skill_button.tscn")

@onready var skills = $Actions/Hbox

var current_unit : Node3D

signal move(unit)

# Called when the node enters the scene tree for the first time.
func display_actions(unit):
	current_unit = unit
	var m_button = SKILL_BUTTON.instantiate()
	skills.add_child(m_button)
	m_button.text = "Move"
	m_button.was_pressed.connect(button_pressed)
	m_button.has_enough_ap(unit.action_points)

func button_pressed(button):
	match button.type:
		0:
			move.emit(current_unit)
	
	for i in skills.get_child_count():
		skills.get_child(i).queue_free()
	
	current_unit = null

func _input(event: InputEvent) -> void:
	if current_unit != null and event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			match event.keycode:
				KEY_1:
					if skills.get_child(0).active:
						button_pressed(skills.get_child(0))
