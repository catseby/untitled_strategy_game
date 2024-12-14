extends Node3D

const PCU = preload("res://level/prefab/units/human.tscn")

@export var units : Array[Node] = []
@export var map : GridMap
@export var action_indicator : Node3D
@export var combat_ui : Control

func queue_units(queue : Array[Node]) -> void:
	units.append_array(queue)
	return

func _init() -> void:
	visible = false


func _ready() -> void:
	var pcu = PCU.instantiate()
	var pcu2 = PCU.instantiate()
	var pcu3 = PCU.instantiate()
	
	pcu.name = "Bob"
	pcu2.name = "Eve"
	pcu3.name = "Brick"

	queue_units([pcu,pcu2])

func add_units() -> void:
	combat_ui.move.connect(action_indicator.movement_indicators)
	combat_ui.skill.connect(action_indicator.skill_indicators)
	action_indicator.action_made.connect(combat_ui._on_confirm_pressed)
	#combat_ui.action_made.connect(action_indicator.action)
	combat_ui.confirm_action.connect(action_indicator.confirm)
	combat_ui.cancel_action.connect(action_indicator.cancel)

	
	for i in units.size():
		
		get_parent().get_parent().turn_order.add_child(units[i])
		units[i].global_position = get_child(i).global_position
		
		units[i].await_command.connect(combat_ui.display_actions)
		units[i].await_command.connect(action_indicator.highlight_indicators)
		units[i].next.connect(get_parent().get_parent().next)
		
		units[i].add_to_group("Hunters")
		
	queue_free()
