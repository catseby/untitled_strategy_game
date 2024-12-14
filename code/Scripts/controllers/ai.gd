extends Node

const GridCalculator = preload("res://code/scripts/grid_calculator.gd")

@onready var map = get_parent().get_parent().get_node("Map")

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
	var global_position : Vector3
	var skill : Node
	var type = ACTION.MOVE
	var cells : Array[Vector3i] = []
	
	func _init(new_position : Vector3,new_global_position : Vector3, new_cells : Array[Vector3i] = [], new_type = ACTION.MOVE, new_skill : Node = null) -> void:
		position = new_position
		global_position = new_global_position
		cells = new_cells
		type = new_type
		skill = new_skill

class Values:
	var distance_to_enemy = 0.01
	var valid_target = 100
	var invalid_target = -4
	var invalid_action = -9999

var action_array : Array[Action] = []
var group : String


func asses_situation():
	var units = get_tree().get_nodes_in_group(group)
	var enemies = get_tree().get_nodes_in_group("Hunters")
	
	match state:
		ADVANCE,ENGAGE:
			for unit in units:
				var exit_loop = false
				
				for enemy in enemies:
					
					if round(enemy.global_position.distance_to(unit.global_position)) < unit.move_range * 1.5:
							state = ENGAGE
							print("state = ENGAGE")
							exit_loop = true
							break
					else:
							state = ADVANCE
							print("state = ADVANCE")
							exit_loop = true
							break
						
				if exit_loop:
					break

func fetch_action(unit):
	if unit.action_points <= 0:
		unit.rest()
		return
	if action_array.is_empty():
		print("thinking")
		asses_situation()
		await calculate_turn(unit)
	
	var arr = []
	for action in action_array:
		arr.append(action.global_position)
	#print("final post " + str(arr))
	
	var action : Action = action_array.pop_front()
	var gc = GridCalculator.new(unit.global_position,map)
	
	#
	#print("av" + str(action.position) + " action.position")
	#print("av" + str(action.cells) + " action.cells")
	
	match action.type:
		ACTION.MOVE:
			#print("MOVE")
			if action.position == Vector3.ZERO:
				action_array = []
				#print("wth")
				unit.rest()
			else:
				var path = gc.get_new_path(action.cells,unit,action.position)
				var pathV3 : Array[Vector3]
				for p in path:
					pathV3.push_back(unit.to_global(Vector3(p.x * 2,0,p.y * 2)))
				#print(str(path) + " path")
				unit.move(pathV3)
		ACTION.SKILL:
			#gc.global_position = action.global_position
			#print("SKILL")
			var new_aoe = []
			#print("ddd" + str(action.cells.size()))
			for cell in action.cells:
				#print("ddd " + str(action.position))
				cell = Vector3i(action.position) + cell
				new_aoe.append(cell)
			#print(new_aoe)
			gc.apply_skill(action.skill,new_aoe)
			unit.skill()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calculate_turn(unit):
	var position = unit.global_position 
	var ap = unit.action_points
	var t_arr : Array[Action] = [Action.new(Vector3.ZERO,position)]
	var possible_turns : Array[Array] = [t_arr]
	
	var skill_count = unit.skills.get_child_count() + 1
	
	for i in ap:
		
		var new_possible_turns : Array[Array] = []
		
		for j in skill_count:
			
			if j == 0: #-----------MOVE ACTION---------------------
				#--------------------------------------------------
				for turn : Array[Action] in possible_turns:
					
					var last_action = turn[turn.size()-1]
					
					if last_action.type == ACTION.SKILL:
						continue
					
					var gc = GridCalculator.new(last_action.global_position,map)
					var available_cells = gc.get_available_cells(unit.move_range)
					
					for l in available_cells.size():
						var action = Action.new(available_cells[l],last_action.global_position + Vector3(available_cells[l] * Vector3i(2,0,2)),available_cells)
						var t_arr2 : Array[Action] = [action] 
						if i == 0:
							new_possible_turns.append(t_arr2)
						else:
							var arr : Array[Action] = turn + t_arr2
							new_possible_turns.append(arr)
				
			elif j != skill_count and state != ADVANCE:
				
				var skill = unit.skills.get_child(j-1)
				
				for turn : Array[Action] in possible_turns:
					
					var last_action = turn[turn.size()-1]
					
					if last_action.type == ACTION.SKILL:
						continue
					
					var gc = GridCalculator.new(last_action.global_position,map)
					var available_cells

							#
							#action.cells = gc.get_rotated_cells(action.cells,angl)
					
					if skill.require_target:
						available_cells = gc.get_available_visible_cells(skill.range)
					else:
						available_cells = gc.get_aoe_cells(skill.range)[1]
					
					print("avvv" + str(available_cells[0]))
					
					if not skill.include_self:
						available_cells.remove_at(available_cells.find(Vector3i.ZERO))
					
					for l in available_cells.size():
						var action = Action.new(available_cells[l],last_action.global_position + Vector3(available_cells[l] * Vector3i(2,0,2)),skill.AOE,ACTION.SKILL,skill)
						
						if skill.require_target:
							var dir = Vector2.ZERO.direction_to(Vector2(last_action.position.x,last_action.position.z))
							var angl = rad_to_deg(-dir.angle())
							action.cells = gc.get_rotated_cells(action.cells,angl)
						
						var t_arr2 : Array[Action] = [action] 
						if i == 0:
							new_possible_turns.append(t_arr2)
						else:
							var arr : Array[Action] = turn + t_arr2
							new_possible_turns.append(arr)
		
		
		possible_turns += new_possible_turns
		#print("stage " + str(i) + " - " + str(possible_turns.size()))
	
	#for turn in possible_turns:
		#var arr = []
		#for action in turn:
			#arr.append(action.global_position)
		#print(arr)
	
	#---------ASSIGN VALUES TO POSSIBLE TURNS-----------
	
	var unsorted_indexes = []
	for i in possible_turns.size():
		var value = calculate_value(possible_turns[i],unit)
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
	
	for i in sorted_indexes.size():
		print("Nr." + str(i) + " " + str(sorted_indexes[i][1]))
		if i == 10:
			break
	
	var factor = 0.01
	var move_rating = round((sorted_indexes.size()-1) * factor)
	var rand = randi_range(0,move_rating)
	var index = sorted_indexes[0][0] #------------------[rand][] for random factor!!!!
	#print("turn rating: " + str(rand) + "/" + str(move_rating) + " - " + str(rand/move_rating * 100) + "%")
	
	var arr = []
	for i in rand + 1:
		var turn = possible_turns[i]
		var val = 0
		for action in turn:
			val += action.value
		arr.append(val)
	#print("values" + str(arr))
	
	action_array = possible_turns[index]
	
	var final_arr = []
	for action in action_array:
		final_arr.append(action.position)
	#print("final pre " + str(final_arr))
	
	
	#print("end value id - " + str(index)) 

	
	return



func calculate_value(collection : Array[Action],unit):
	var value : float = 0.0
	var allies = get_tree().get_nodes_in_group("Guards")
	var enemies = get_tree().get_nodes_in_group("Hunters")
	var values = Values.new()
	match state:
		ADVANCE:
			var last_action = collection[collection.size()-1]
			if last_action.type == ACTION.MOVE:
				value = calculate_value_move(last_action,enemies,collection.size())
			else:
				value += values.invalid_action * collection.size()
		
		ENGAGE:
			
			var last_action = collection[collection.size()-1]
			if last_action.type == ACTION.SKILL:
				
				var skill = last_action.skill
				var position = last_action.global_position
				var CONDITIONS = skill.CONDITIONS
				
				var targets : Array[Node]
				if skill.targets == skill.TARGETS.ENEMY:
					targets = enemies
				else:
					targets = allies
				
				var condition_size = skill.conditions.size()
				
				var valid = false
				for target in targets:
					for cell in last_action.skill.AOE:
						
						var target_position = target.global_position
						if target == unit and collection.size() >= 2:
							target_position = collection[collection.size()-2].global_position
						
						if position + Vector3(Vector3i(2,0,2) * cell) == target_position:
							#print(Vector3(Vector3i(2,0,2) * cell))
							var multiplier : float = 0.0
							#print(target)
							if skill.conditions.has(CONDITIONS.HIGH_HP) and target.hit_points / target.max_hit_points > 0.5:
								print("high hp")
								multiplier += 1.0 / condition_size
							if skill.conditions.has(CONDITIONS.LOW_HP) and target.hit_points / target.max_hit_points < 0.5:
								print("low hp")
								multiplier += 1.0 / condition_size
							if skill.conditions.has(CONDITIONS.ANYONE):
								print("anyone")
								multiplier += 1.0 / condition_size
							
							if multiplier != 0.0:
								print("aaaaaaaaa")
								valid = true
							
							value += values.valid_target * multiplier# / collection.size()
				#
				if valid:
					value = (value * (1+skill.value)) / collection.size()
				else:
					value = values.invalid_action * collection.size()
				
				#print("ALLY " + str(value) + " " + str(collection.size()))
				
			else:
				value = calculate_value_move(last_action,enemies,collection.size())

	return value


func calculate_value_move(last_action,enemies,size):
	var values = Values.new()
	
	var end_position = last_action.global_position
	var closest = enemies[0].global_position.distance_to(end_position)
	
	for enemy in enemies:
		var new_position = enemy.global_position.distance_to(end_position)
		if closest > new_position:
			closest = new_position
	
	return -(closest * size * values.distance_to_enemy)
