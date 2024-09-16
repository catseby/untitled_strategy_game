extends GridMap

@onready var axis = $Axis
@onready var indicator = $Indicator
@onready var active_unit : Node3D

@export var map : GridMap

signal move(move_position)

var indicator_position = Vector3i.ZERO

func set_indicator(ind_position):
	ind_position = to_local(ind_position)
	var snap_position = local_to_map(ind_position)
	
	if get_cell_item(snap_position) != -1:
		indicator_position = map_to_local(snap_position)
		indicator.position = indicator_position

func action():
	active_unit.move(to_global(indicator_position))
	clear_indicators()


func clear_indicators():
	visible = false
	indicator.position = Vector3(1,0,1)
	clear()
	
	active_unit = null
	
	for i in axis.get_child_count():
		axis.get_child(i).clear()


func show_indicators(unit):
	visible = true
	active_unit = unit
	
	global_position = unit.global_position - Vector3(1,0,1)
	
	var coords : Array[Vector3i] = []
	
	var range = unit.move_range
	var range_size = range * 2 + 1
	
	var next_pass : Array[Vector3i] = [Vector3i.ZERO]
	for i in range:
		var fresh_next_pass : Array[Vector3i] = []
		
		while next_pass.size() > 0:
			
			var new_cell = next_pass.pop_front()
			if map.is_cell_free(new_cell * Vector3i(2,0,2), global_position):
				coords.append(new_cell)
				set_cell_item(new_cell,0,0)
				
				fresh_next_pass.append(new_cell + Vector3i(1,0,0))
				fresh_next_pass.append(new_cell + Vector3i(-1,0,0))
				fresh_next_pass.append(new_cell + Vector3i(0,0,1))
				fresh_next_pass.append(new_cell + Vector3i(0,0,-1))
			
		next_pass.append_array(fresh_next_pass)

	#for xi in range_size:
		#
		#var x = xi - range
		#
		#for yi in range_size:
			#
			#var y = yi - range
			#
			#var xd = abs(abs(x) - range)
			#
			#if xd >= abs(y):
				#if map.is_cell_free(Vector3i(x*2,0,y*2), global_position):
					#coords.append(Vector3i(x,0,y))
					#set_cell_item(Vector3i(x,0,y),0,0)
	
	for i in coords.size():
		if !coords.has(coords[i] - Vector3i(0,0,-1)):
			axis.get_child(0).set_cell_item(coords[i],1,0)
		
		if !coords.has(coords[i] - Vector3i(0,0,1)):
			axis.get_child(1).set_cell_item(coords[i],1,10)
		
		if !coords.has(coords[i] - Vector3i(1,0,0)):
			axis.get_child(2).set_cell_item(coords[i],1,22)
		
		if !coords.has(coords[i] - Vector3i(-1,0,0)):
			axis.get_child(3).set_cell_item(coords[i],1,16)
