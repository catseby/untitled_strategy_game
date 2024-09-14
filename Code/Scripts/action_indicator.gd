extends Node3D

@onready var axis = $Axis

func show_indicators(unit):
	global_position = unit.global_position
	
	var coords : Array[Vector3i] = []
	
	var range = unit.move_range
	var range_size = range * 2 + 1
	for x in range_size:
		for y in range_size:
			coords.append(Vector3i(x-range,0,y-range))
	
	for i in coords.size():
		if !coords.has(coords[i] - Vector3i(0,0,-1)):
			axis.get_child(0).set_cell_item(coords[i],0,0)
		
		if !coords.has(coords[i] - Vector3i(0,0,1)):
			axis.get_child(1).set_cell_item(coords[i],0,10)
		
		if !coords.has(coords[i] - Vector3i(1,0,0)):
			axis.get_child(2).set_cell_item(coords[i],0,22)
		
		if !coords.has(coords[i] - Vector3i(-1,0,0)):
			axis.get_child(3).set_cell_item(coords[i],0,16)
