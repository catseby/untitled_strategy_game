extends "res://code/scripts/spawns/spawn.gd"

@export var action_indicator : Node3D
@export var combat_ui : Control

#func _ready() -> void:
	#var pcu = UNIT.instantiate()
	#var pcu2 = UNIT.instantiate()
	#var pcu3 = UNIT.instantiate()
	#
	#pcu.name = "Bob"
	#pcu2.name = "Eve"
	#pcu3.name = "Brick"
#
	#queue_units([pcu,pcu2])

func add_units() -> void:
	combat_ui.move.connect(action_indicator.movement_indicators)
	combat_ui.skill.connect(action_indicator.skill_indicators)
	action_indicator.action_made.connect(combat_ui._on_confirm_pressed)
	combat_ui.confirm_action.connect(action_indicator.confirm)
	combat_ui.cancel_action.connect(action_indicator.cancel)

	var gc = GridCalculator.new(global_position,map)
	var available_spots = gc.get_available_cells(units.size())
	available_spots.shuffle()

	for i in units.size():

		units[i].global_position = to_global(available_spots[i] * Vector3i(2,0,2))
		units[i].group = team
		units[i].add_to_group(team)

		get_parent().get_parent().turn_order.add_child(units[i])

		units[i].await_command.connect(combat_ui.display_actions)
		units[i].await_command.connect(action_indicator.highlight_indicators)
		units[i].next.connect(get_parent().get_parent().next)

	queue_free()
