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
	

var action_array : Array[Action] = []

func fetch_action(unit):
	if action_array.is_empty():
		await calculate_turn(unit)
	
	var action : Action = action_array.pop_front()
	
	match action.type:
		ACTIONS.MOVE:
			print("ai move")
		ACTIONS.SKILL:
			print("ai skill")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calculate_turn(unit):
	var ap = unit.action_points
	var possible_turns = []
	
	var gc = GridCalculator.new(unit.global_position,map)
	var skill_count = unit.skills.get_child_count()
	
	print("pre")
	var available_move_cells = gc.get_available_cells(unit.move_range)
	print(available_move_cells.size())
	print("post")
	for i in ap:
		var index = 0
		for j in skill_count:
			if j == 0:
				for k in available_move_cells.size():
					if i == 0:
						var arr : Array[Action] = [Action.new()]
						possible_turns.append(arr)
					else:
						possible_turns[index].append(Action.new())
					index += 1
		print(index)
	
	action_array = possible_turns[0]
	#print(possible_turns)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
