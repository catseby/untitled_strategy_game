extends Node3D

const PCU = preload("res://Level/Prefab/player_controlled_unit.tscn")

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

	queue_units([pcu,pcu2,pcu3])

func add_units() -> void:
	combat_ui.move.connect(action_indicator.show_indicators)
	action_indicator.action_made.connect(combat_ui._on_confirm_pressed)
	combat_ui.cancel_action.connect(action_indicator.cancel)

	
	for i in units.size():
		
		get_parent().turn_order.add_child(units[i])
		units[i].global_position = get_child(i).global_position
		
		units[i].await_command.connect(combat_ui.display_actions)
		units[i].next.connect(get_parent().next)
		
	queue_free()
