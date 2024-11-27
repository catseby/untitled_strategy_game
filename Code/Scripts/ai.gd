extends Node

const GridCalculator = preload("res://Code/Scripts/grid_calculator.gd")

@onready var map = get_parent().get_node("Map")

enum ACTION {
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
	var type = ACTION.MOVE
	var cells = []
	
	func _init(new_position : Vector3, new_cells = [], new_type = ACTION.MOVE) -> void:
		position = new_position
		cells = new_cells
		type = new_type

class Values:
	var distance_to_enemy = 0.01

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
		ACTION.MOVE:
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
		ACTION.SKILL:
			print("ai skill")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calculate_turn(unit):
	var position = unit.global_position 
	var ap = unit.action_points
	var possible_turns = [[Action.new(Vector3.ZERO)]]
	
	var skill_count = unit.skills.get_child_count() + 1
	
	for i in ap:
		
		var new_possible_turns = []
		
		for j in skill_count:
			if j == 0:
				
				for k in possible_turns.size():
					#var current_position = (possible_turns[k][i-1].position * Vector3(2,0,2)) + position
					var current_position : Vector3
					for l in possible_turns[k].size():
						var index = possible_turns[k].size() - 1 - l
						if possible_turns[k][index].type == ACTION.MOVE:
							current_position = (possible_turns[k][index].position * Vector3(2,0,2)) + position
							break
					
					var gc = GridCalculator.new(current_position,map)
					var available_cells = gc.get_available_cells(unit.move_range)
					
					for l in available_cells.size():
						var action = Action.new(available_cells[l],available_cells)
						if i == 0:
							new_possible_turns.append([action])
						else:
							var arr = []
							arr.append_array(possible_turns[k])
							arr.append(action)
							new_possible_turns.append(arr)
				
			elif j != skill_count:
				
				var skill = unit.skills.get_child(j-1)
				
				print(skill)
				for k in possible_turns.size():
					
					var current_position : Vector3
					for l in possible_turns[k].size():
						var index = possible_turns[k].size() - 1 - l
						if possible_turns[k][index].type == ACTION.MOVE:
							current_position = (possible_turns[k][index].position * Vector3(2,0,2)) + position
							break
					
					var gc = GridCalculator.new(current_position,map)
					var available_cells
					
					if skill.require_target:
						available_cells = gc.get_available_visible_cells(skill.range)
					else:
						available_cells = gc.get_aoe_cells(skill.range)
					
					for l in available_cells.size():
						var action = Action.new(available_cells[l],available_cells,ACTION.SKILL)
						if i == 0:
							new_possible_turns.append([action])
						else:
							var arr = []
							arr.append_array(possible_turns[k])
							arr.append(action)
							new_possible_turns.append(arr)
		
		possible_turns = new_possible_turns
	
	
	
	#---------ASSIGN VALUES TO POSSIBLE TURNS-----------
	var unsorted_indexes = []
	for i in possible_turns.size():
		var value = 0
		for action in possible_turns[i]:
			action = calculate_value(unit,action)
			value += action.value
		unsorted_indexes.append([i,value])
	
	
	#---------SORT BEST TO WORST MOVES
	
	var sorted_indexes = [unsorted_indexes[0]]
	for i in unsorted_indexes.size():
		if i == 0:
			continue
			
		var index = unsorted_indexes[i]
		for j in sorted_indexes.size():
			
			if j >= sorted_indexes.size() - 1:
				sorted_indexes.append(index)
				break
			elif index[1] > sorted_indexes[j][1]:
				sorted_indexes.insert(j,index)
				break
	
	var factor = 0.01
	var move_rating = round((sorted_indexes.size()-1) * factor)
	var rand = randi_range(0,move_rating)
	var index = sorted_indexes[rand][0]
	print(str(rand) + "/" + str(move_rating) + " - " + str(rand/move_rating * 100) + "%")
	
	action_array = possible_turns[index]


func choose_turn(unit,possible_turns):
	for turn in possible_turns:
		for action in turn:
			action = calculate_value(unit,action)

func calculate_value(unit,action):
	var values = Values.new()
	match state:
		ADVANCE:
			var position = unit.global_position + (action.position * Vector3(2,0,2))
			var enemies = get_tree().get_nodes_in_group("Hunters")
			var shortest_distance = position.distance_to(enemies[0].global_position)
			for i in enemies.size():
				var new_distance = position.distance_to(enemies[i].global_position)
				if shortest_distance > new_distance:
					shortest_distance = new_distance
			action.value -= shortest_distance * values.distance_to_enemy
	return action
