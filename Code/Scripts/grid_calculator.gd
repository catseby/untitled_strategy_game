extends Node

var map : GridMap
var global_position : Vector3

func _init(new_global_position : Vector3 = Vector3.ZERO, new_map : GridMap = null) -> void:
	map = new_map
	global_position = new_global_position

func get_new_path(cells,active_unit : Node3D,end_position):
	var AS = AStarGrid2D.new()
	AS.region = Rect2i(-active_unit.move_range-1,-active_unit.move_range-1,
	active_unit.move_range * 2 + 2,active_unit.move_range * 2 + 2)
	AS.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AS.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AS.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AS.update()
	
	for cell in cells:
		AS.set_point_weight_scale(Vector2i(cell.x,cell.z),cells.find(cell))
		
		if  !cells.has(cell + Vector3i(1,0,0)): #-----------------------RIGHT
			AS.set_point_solid(Vector2i(cell.x,cell.z) + Vector2i(1,0))
		if  !cells.has(cell + Vector3i(-1,0,0)):#-----------------------LEFT
			AS.set_point_solid(Vector2i(cell.x,cell.z) + Vector2i(-1,0))
		if  !cells.has(cell + Vector3i(0,0,1)):#------------------------DOWN
			AS.set_point_solid(Vector2i(cell.x,cell.z) + Vector2i(0,1))
		if  !cells.has(cell + Vector3i(0,0,-1)):#-----------------------UP
			AS.set_point_solid(Vector2i(cell.x,cell.z) + Vector2i(0,-1))
	
	var path = AS.get_point_path(Vector2i.ZERO,Vector2i(end_position.x,end_position.z))
	return path

func get_available_cells(range,include_self : bool = false) -> Array[Vector3i]:
	var coords : Array[Vector3i] = []
	var range_size = range * 2 + 1
	
	var next_pass : Array[Vector3i] = [Vector3i.ZERO]
	for i in range:
		var fresh_next_pass : Array[Vector3i] = []
		
		while next_pass.size() > 0:
			var new_cell = next_pass.pop_front()
			
			if map == null or map.is_cell_free(new_cell * Vector3i(2,0,2), global_position) and !coords.has(new_cell):
				if map == null or !map.is_cell_occupied(new_cell * Vector3i(2,0,2), global_position) or new_cell == Vector3i.ZERO:
					coords.append(new_cell)
					
					fresh_next_pass.append(new_cell + Vector3i(1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(-1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(0,0,1))
					fresh_next_pass.append(new_cell + Vector3i(0,0,-1))
		
		next_pass.append_array(fresh_next_pass)
	
	return coords
