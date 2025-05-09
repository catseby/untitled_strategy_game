extends "res://code/scripts/spawns/spawn.gd"


const AI = preload("res://level/prefab/controllers/ai.tscn")

@export var enemy_teams : Array[TEAMS]
@onready var ai = AI.instantiate()

#func _ready() -> void:
	#var pcu = UNIT.instantiate()
	#var pcu2 = UNIT.instantiate()
	#var pcu3 = UNIT.instantiate()
	#
	#pcu.name = "asd"
	#pcu2.name = "Carl"
	#pcu3.name = "Bot"
	#
	#
	#queue_units([pcu,pcu2])

func add_units() -> void:
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
	ai.friendly_team = team
	for hostile in enemy_teams:
		ai.enemy_teams.append(TEAMS.keys()[hostile])

	var gc = GridCalculator.new(global_position,map)
	var available_spots = gc.get_available_cells(units.size())
	available_spots.shuffle()

	for i in units.size():

		units[i].global_position = to_global(available_spots[i] * Vector3i(2,0,2))
		units[i].group = team

		units[i].add_to_group(group)
		units[i].add_to_group(team)

		get_parent().get_parent().turn_order.add_child(units[i])

		units[i].await_command.connect(ai.fetch_action)
		units[i].next.connect(get_parent().get_parent().next)
		units[i].moved.connect(fog_of_war.unit_moved)

	queue_free()
