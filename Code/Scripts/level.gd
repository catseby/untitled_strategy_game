extends Node3D

@onready var player_spawn = $Player_Spawn
@onready var turn_order = $Turn_Order
@onready var ui = $Combat_UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_spawn.add_units()
	$Enemy_Spawn.add_units()
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
	
	
	ui.update_turn_order(turn_order.get_children())

#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#if event.is_pressed():
			#if event.keycode == KEY_ESCAPE:
				#get_tree().quit()
