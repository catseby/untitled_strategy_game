extends Control

const SKILL_BUTTON = preload("res://Level/UI/skill_button.tscn")
const TURN_INDICATOR = preload("res://Level/UI/turn_indicator.tscn")

@onready var skills = $Center/Actions
@onready var turn_order = $Right/Turn_Order

@onready var cancel = $Center/Cancel
@onready var cancel_text = $Center/Cancel/Vbox/Title

@onready var yesno = $Center/YesNo
@onready var yesno_text = $Center/YesNo/Vbox/Title

var current_unit : Node3D
var current_key = null

signal move(unit)
signal cancel_action

signal user_choice(choice : bool)

# Called when the node enters the scene tree for the first time.
func display_actions(unit):
	current_unit = unit
	
	var m_button = SKILL_BUTTON.instantiate()
	skills.add_child(m_button)
	m_button.text = "Move"
	m_button.was_pressed.connect(button_pressed)
	m_button.key = KEY_1
	m_button.check_required_ap(unit.action_points)
	
	for skill in unit.skills.get_children():
		var s_button = SKILL_BUTTON.instantiate()
		skills.add_child(s_button)
		s_button.text = skill.name
		s_button.was_pressed.connect(button_pressed)
		s_button.key = KEY_4
		s_button.check_required_ap(unit.action_points)
	
	var r_button = SKILL_BUTTON.instantiate()
	skills.add_child(r_button)
	r_button.text = "Rest"
	r_button.was_pressed.connect(button_pressed)
	r_button.key = KEY_0
	r_button.required_action_points = 0
	r_button.check_required_ap(unit.action_points)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !skills.visible:
		if event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_ENTER and current_key != null:
				_on_confirm_pressed()
			elif event.keycode == KEY_ESCAPE:
				_on_cancel_pressed()

func button_pressed(button):
	if skills.visible:
		match button.key:
			KEY_0:
				yesno.visible = true
				yesno_text.text = "End Turn?"
				skills.visible = false
				current_key = KEY_0
				
				var confirmed = await user_choice
				
				skills.visible = true
				
				if confirmed:
					current_unit.rest()
					clear()
					cancel_action.emit()
				current_key = null
			
			KEY_1:
				move.emit(current_unit)
				skills.visible = false
				cancel.visible = true
				cancel_text.text = "Choose Your Destination."
				
				var confirmed = await user_choice
				
				skills.visible = true
				
				if confirmed:
					clear()
				else:
					cancel_action.emit()
	
	elif current_key != null and button.key == current_key:
		_on_confirm_pressed()


func clear():
	for i in skills.get_child_count():
		skills.get_child(i).queue_free()
	
	current_unit = null

func update_turn_order(array):
	for child in turn_order.get_children():
		child.queue_free()
	
	for i in array.size():
		var unit = array[array.size() - 1 - i]
		var ti = TURN_INDICATOR.instantiate()
		turn_order.add_child(ti)
		ti.text = str(unit.turn_order) + " " + str(unit.name)


func _on_cancel_pressed() -> void:
	yesno.visible = false
	cancel.visible = false
	user_choice.emit(false)

func _on_confirm_pressed() -> void:
	yesno.visible = false
	cancel.visible = false
	user_choice.emit(true)
