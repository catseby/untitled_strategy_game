extends Node

const GridCalculator = preload("res://Code/Scripts/grid_calculator.gd")

@onready var map = get_parent().get_node("Map")

enum ACTIONS {
	MOVE,
	SKILL
}

var state = ADVANCE
enum {
	ADVANCE,
	ENGAGE,
	RETREAT,
	PATROL
}

class Action:
	var value : float = 0.0
	var position : Vector3
	var type = ACTIONS.MOVE
	var cells = []
	
	func _init(new_position : Vector3, new_cells = []) -> void:
		position = new_position
		cells = new_cells

class Values:
	var distance_to_enemy = 1.0
	var distance_to_enemy_multi = 1

var action_array : Array = []

func fetch_action(unit):
	if unit.action_points <= 0:
		unit.rest()
		return
	if action_array.is_empty():
		await calculate_turn(unit)
	
	var action : Action = action_array.pop_front()
	var gc = GridCalculator.new(unit.global_position - Vector3(1,0,1),map)
	
	#print(str(action.position) + " action.position")
	#print(str(action.cells) + " action.cells")
	
	match action.type:
		ACTIONS.MOVE:
			if action.position == Vector3.ZERO:
				action_array = []
				unit.rest()
			else:
				var path = gc.get_new_path(action.cells,unit,action.position)
				var pathV3 : Array[Vector3]
				for p in path:
					pathV3.push_back(unit.to_global(Vector3(p.x * 2,0,p.y * 2)))
				print(str(pathV3) + " path")
				unit.move(pathV3)
		ACTIONS.SKILL:
			print("ai skill")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calculate_turn(unit):
	var position = unit.global_position 
	var ap = unit.action_points
	var possible_turns = [[Action.new(Vector3.ZERO)]]
	
	var skill_count = unit.skills.get_child_count()
	
	for i in ap:
		
		var new_possible_turns = []
		
		for j in skill_count:
			if j == 0:
				
				for k in possible_turns.size():
					var current_position = (possible_turns[k][i-1].position * Vector3(2,0,2)) + position
					
					var gc = GridCalculator.new(current_position,map)
					var available_cells = gc.get_available_cells(unit.move_range)
					
					for l in available_cells.size():
						if i == 0:
							new_possible_turns.append([Action.new(available_cells[l],available_cells)])
						else:
							var action = Action.new(available_cells[l],available_cells)
							var arr = []
							arr.append_array(possible_turns[k])
							arr.append(action)
							new_possible_turns.append(arr)
		
		#print("""
		#
		#
		#""")
		#
		#print(new_possible_turns)
		possible_turns = new_possible_turns
	
	
	var best_turn = possible_turns[0]	
	var best_value = -1000
	for turn in possible_turns:
		var value = 0
		for action in turn:
			action = calculate_value(unit,action)
			value += action.value
		if value > best_value:
			best_turn = turn
			best_value = value
	#
	#print(best_turn[0].position)
	#print(best_turn[1].position)
	action_array = best_turn


func calculate_value(unit,action):
	match state:
		ADVANCE:
			var position = unit.global_position + (action.position * Vector3(2,0,2))
			var enemies = get_tree().get_nodes_in_group("Hunters")
			var shortest_distance = position.distance_to(enemies[0].global_position)
			for i in enemies.size():
				var new_distance = position.distance_to(enemies[i].global_position)
				if shortest_distance > new_distance:
					shortest_distance = new_distance
			action.value -= shortest_distance
	return action
