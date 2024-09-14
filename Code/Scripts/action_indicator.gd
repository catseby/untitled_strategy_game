extends Node3D

@onready var axis = $Axis

@export var map : GridMap

func show_indicators(unit):
	global_position = unit.global_position
	
	var coords : Array[Vector3i] = []
	
	var range = unit.move_range
	var range_size = range * 2 + 1
	for xi in range_size:
		
		var x = xi - range
		
		for yi in range_size:
			
			var y = yi - range
			
			var xd = abs(abs(x) - range)
			
			
			if xd >= abs(y):
				if map.is_cell_free(Vector3i(x*2,0,y*2), global_position):
					coords.append(Vector3i(x,0,y))
	
	for i in coords.size():
		if !coords.has(coords[i] - Vector3i(0,0,-1)):
			axis.get_child(0).set_cell_item(coords[i],0,0)
		
		if !coords.has(coords[i] - Vector3i(0,0,1)):
			axis.get_child(1).set_cell_item(coords[i],0,10)
		
		if !coords.has(coords[i] - Vector3i(1,0,0)):
			axis.get_child(2).set_cell_item(coords[i],0,22)
		
		if !coords.has(coords[i] - Vector3i(-1,0,0)):
			axis.get_child(3).set_cell_item(coords[i],0,16)
