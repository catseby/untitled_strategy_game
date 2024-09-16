extends GridMap

@onready var axis = $Axis
@onready var indicator = $Indicator

@export var map : GridMap

func set_indicator(ind_position):
	ind_position = to_local(ind_position)
	var snap_position = local_to_map(ind_position)
	
	if get_cell_item(snap_position) != -1:
		indicator.position = map_to_local(snap_position)

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
					set_cell_item(Vector3i(x,0,y),0,0)
	
	for i in coords.size():
		if !coords.has(coords[i] - Vector3i(0,0,-1)):
			axis.get_child(0).set_cell_item(coords[i],1,0)
		
		if !coords.has(coords[i] - Vector3i(0,0,1)):
			axis.get_child(1).set_cell_item(coords[i],1,10)
		
		if !coords.has(coords[i] - Vector3i(1,0,0)):
			axis.get_child(2).set_cell_item(coords[i],1,22)
		
		if !coords.has(coords[i] - Vector3i(-1,0,0)):
			axis.get_child(3).set_cell_item(coords[i],1,16)
