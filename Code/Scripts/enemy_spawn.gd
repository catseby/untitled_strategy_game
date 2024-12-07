extends Node3D

const GridCalculator = preload("res://Code/Scripts/grid_calculator.gd")

const PCU = preload("res://Level/Prefab/player_controlled_unit.tscn")
const AI = preload("res://Level/Prefab/ai.tscn")

@onready var ai = AI.instantiate()
@onready var map = get_parent().get_node("Map")

@export var units : Array[Node] = []
@export var team : String = "Guard"

func queue_units(queue : Array[Node]) -> void:
	units.append_array(queue)
	return

func _init() -> void:
	visible = false


func _ready() -> void:
	var pcu = PCU.instantiate()
	var pcu2 = PCU.instantiate()
	var pcu3 = PCU.instantiate()
	
	pcu.name = "asd"
	pcu2.name = "Carl"
	pcu3.name = "Bot"
	
	
	queue_units([pcu])

func add_units() -> void:
	#combat_ui.move.connect(action_indicator.movement_indicators)
	#combat_ui.skill.connect(action_indicator.skill_indicators)
	#action_indicator.action_made.connect(combat_ui._on_confirm_pressed)
	#combat_ui.cancel_action.connect(action_indicator.cancel)
	
	var group : String
	while true:
		group = ""
		var chars = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890"
		var length = 20
		var n_char = len(chars)
		for i in range(length):
			group += chars[randi()% n_char]
		if get_tree().get_node_count_in_group(group) == 0:
			break
	
	get_parent().add_child(ai)
	ai.group = group
	print(group)
	
	var gc = GridCalculator.new(global_position,map)
	var available_spots = gc.get_available_cells(units.size())
	available_spots.shuffle()
	
	for i in units.size():
		
		get_parent().turn_order.add_child(units[i])
		print(available_spots[i])
		units[i].global_position = to_global(available_spots[i] * Vector3i(2,0,2))
		
		units[i].add_to_group(group)
		units[i].add_to_group(team)

		
		units[i].await_command.connect(ai.fetch_action)
		units[i].next.connect(get_parent().next)
	
	queue_free()
