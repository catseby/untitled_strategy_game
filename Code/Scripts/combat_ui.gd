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


func button_pressed(button):
	match button.type:
		0:
			move.emit(current_unit)
	
	for i in skills.get_child_count():
		skills.get_child(i).queue_free()
