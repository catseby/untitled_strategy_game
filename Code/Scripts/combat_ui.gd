extends Control

const SKILL_BUTTON = preload("res://Level/UI/skill_button.tscn")

@onready var skills = $Center/Actions

var current_unit : Node3D

signal move(unit)

# Called when the node enters the scene tree for the first time.
func display_actions(unit):
	current_unit = unit
	
	var m_button = SKILL_BUTTON.instantiate()
	skills.add_child(m_button)
	m_button.text = "Move"
	m_button.was_pressed.connect(button_pressed)
	m_button.key = KEY_1
	m_button.check_required_ap(unit.action_points)
	
	
	var r_button = SKILL_BUTTON.instantiate()
	skills.add_child(r_button)
	r_button.text = "Rest"
	r_button.was_pressed.connect(button_pressed)
	r_button.key = KEY_0
	r_button.required_action_points = 0
	r_button.check_required_ap(unit.action_points)


func button_pressed(button):
	match button.key:
		KEY_0:
			current_unit.rest()
		KEY_1:
			move.emit(current_unit)
	
	for i in skills.get_child_count():
		skills.get_child(i).queue_free()
	
	current_unit = null

func update_turn_order():
	pass
