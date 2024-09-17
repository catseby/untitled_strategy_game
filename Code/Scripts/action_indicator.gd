extends GridMap

@onready var axis = $Axis
@onready var indicator = $Indicator
@onready var active_unit : Node3D
@onready var indicator_line = $Indicator_Line

@export var map : GridMap

signal move(move_position)

func set_indicator(ind_position):
	ind_position = to_local(ind_position)
	var snap_position = local_to_map(ind_position)
	
	var indicator_position = Vector3i.ZERO
	indicator_position = map_to_local(snap_position)
	
	if get_cell_item(snap_position) != -1 and indicator_position != indicator.position:
		indicator.position = indicator_position
		generate_path(snap_position)

func generate_path(target_position):
	var cells = get_used_cells()
	var current_cell = Vector3i.ZERO
	var path : Array[Vector3] = []
	
	while true:
		
		var p_paths = []
		
		if cells.has(current_cell + Vector3i(1,0,0)):
			p_paths.append(current_cell + Vector3i(1,0,0))
		
		if cells.has(current_cell + Vector3i(-1,0,0)):
			p_paths.append(current_cell + Vector3i(-1,0,0))
		
		if cells.has(current_cell + Vector3i(0,0,1)):
			p_paths.append(current_cell + Vector3i(0,0,1))
		
		if cells.has(current_cell + Vector3i(0,0,-1)):
			p_paths.append(current_cell + Vector3i(0,0,-1))
		
		var b_path = p_paths[0]
		for i in p_paths.size():
			if b_path.distance_to(target_position) > p_paths[i].distance_to(target_position):
				b_path = p_paths[i]
		
		current_cell = b_path
		path.push_back(Vector3(b_path))
		
		if b_path == target_position:
			break
	
	print(path)
	indicator_line.generate_line(path)

func action():
	active_unit.move(to_global(indicator.position))
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
	
	for i in coords.size():
		if !coords.has(coords[i] - Vector3i(0,0,-1)):
			axis.get_child(0).set_cell_item(coords[i],1,0)
		
		if !coords.has(coords[i] - Vector3i(0,0,1)):
			axis.get_child(1).set_cell_item(coords[i],1,10)
		
		if !coords.has(coords[i] - Vector3i(1,0,0)):
			axis.get_child(2).set_cell_item(coords[i],1,22)
		
		if !coords.has(coords[i] - Vector3i(-1,0,0)):
			axis.get_child(3).set_cell_item(coords[i],1,16)
