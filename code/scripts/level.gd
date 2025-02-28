extends Node3D

const UNIT = preload("res://level/prefab/units/human.tscn")


@onready var spawns = $Spawns
@onready var turn_order = $Units
@onready var ui = $Combat_UI
@onready var objectives = $Objectives
@onready var visible_level = $VisibleLevel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for spawn in spawns.get_children():
		spawn.add_units()
	#await get_tree().create_timer(1).timeout
	update_objectives()
	next()

func next():
	for unit in turn_order.get_children():
		unit.turn_order += 10

	var unit_0 = turn_order.get_child(0)
	for i in turn_order.get_child_count(): #Most likekly gonna have to sort it from the back

		if i == 0:
			continue

		var unit = turn_order.get_child(i)

		if unit.turn_order < unit_0.turn_order:
			turn_order.move_child(turn_order.get_child(0),i)
			break

		elif i == turn_order.get_child_count() - 1:
				turn_order.move_child(unit_0,turn_order.get_child_count()-1)

	turn_order.get_child(0).act()

	visible_level.update_fog()
	ui.update_turn_order(turn_order.get_children())

func update_objectives():
	print("UPDATE_OBJECTIVES")
	var messages = []
	for objective in $Objectives.get_children():
		messages.append(objective.get_objective())
		if !objective.complete:
			break
	$Combat_UI.update_objectives(messages)

	if $Objectives.get_child($Objectives.get_child_count()-1).complete:
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://level/scenes/test_win_screen.tscn")


#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#if event.is_pressed():
			#if event.keycode == KEY_ESCAPE:
				#get_tree().quit()
