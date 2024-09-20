extends Node3D

@onready var player_spawn = $Player_Spawn
@onready var turn_order = $Turn_Order

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_spawn.add_units()
	next()

func next():
	turn_order.move_child(turn_order.get_child(0),turn_order.get_child_count()-1)
	
	turn_order.get_child(0).act()
	
	for unit in turn_order.get_children():
		unit.turn_order += 10
