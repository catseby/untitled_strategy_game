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
	
	func _init(new_position : Vector3) -> void:
		position = new_position

class Values:
	var distance_to_enemy = 1.0
	var distance_to_enemy_multi = 1

var action_array : Array[Action] = []

func fetch_action(unit):
	if action_array.is_empty():
		await calculate_turn(unit)
	
	print(action_array)
	
	var action : Action = action_array.pop_front()
	var gc = GridCalculator.new(unit.global_position,map)
	
	match action.type:
		ACTIONS.MOVE:
			var path = gc.get_new_path(map.get_used_cells(),unit,map.local_to_map(map.to_local(action.position)))
			var pathV3 : Array[Vector3]
			for p in path:
				pathV3.push_back(Vector3(p.x,0,p.y))
			#print(pathV3)
			unit.move(pathV3)
		ACTIONS.SKILL:
			print("ai skill")
	
	if unit.action_points <= 0:
		unit.rest()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calculate_turn(unit):
	var ap = unit.action_points
	var possible_turns = []
	
	var skill_count = unit.skills.get_child_count()
	
	for i in ap:
		var index = 0
		var gc = GridCalculator.new(unit.global_position,map)
		
		if i != 0 and possible_turns[index][i-1].type == ACTIONS.MOVE:
			gc.global_position = map.to_global(map.map_to_local(possible_turns[index][i-1].position))
		
		for j in skill_count:
			if j == 0:
				var available_cells = gc.get_available_cells(unit.move_range)
				for k in available_cells.size():
					if i == 0:
						var arr : Array[Action] = [calculate_value(Action.new(available_cells[k]))]
						#var arr : Array[Action] = [calculate_value(Action.new(Vector3(unit.to_global(available_cells[k])) + unit.global_position))]
						possible_turns.append(arr)
					else:
						print(possible_turns[index-1])
						possible_turns[index].append(calculate_value(Action.new(available_cells[k])))
						#possible_turns[index].append(calculate_value(Action.new(Vector3(unit.to_global(available_cells[k])) + possible_turns[index][i-1].position)))
						index += 1
		
		print(possible_turns.size())
		print(possible_turns[possible_turns.size()-1])
	
	var best_turn = possible_turns[0]
	var best_value = -1000
	for turn in possible_turns:
		var value = 0
		for action in turn:
			value += action.value
		if value > best_value:
			best_turn = turn
			best_value = value
	
	print(possible_turns)
	print(best_turn)
	print(best_turn[0].position)
	print(best_turn[1].position)
	action_array = best_turn
	#print(possible_turns)

func calculate_value(action):
	match state:
		ADVANCE:
			var enemies = get_tree().get_nodes_in_group("Hunters")
			var shortest_distance = action.position.distance_to(enemies[0].global_position)
			for i in enemies.size():
				var new_distance = action.position.distance_to(enemies[i].global_position)
				if shortest_distance > new_distance:
					shortest_distance = new_distance
			action.value -= shortest_distance
	return action
