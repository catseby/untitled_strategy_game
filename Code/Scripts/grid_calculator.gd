extends Node

var map : GridMap
var global_position : Vector3

class Tile:
	var position
	var is_wall = false
	
	func _init(pos : Vector3i, wall : bool = false) -> void:
		position = pos
		is_wall = wall

func _init(new_global_position : Vector3 = Vector3.ZERO, new_map : GridMap = null) -> void:
	map = new_map
	global_position = new_global_position

func apply_skill(skill,aoe):
	for area in aoe:
		if map.is_cell_occupied(area * Vector3i(2,0,2), global_position):
			skill.apply_effect(map.get_unit(area * Vector3i(2,0,2), global_position))

func get_rotated_cells(cells,deg) -> Array[Vector3i]:
	var new_cells : Array[Vector3i] = []
	for cell in cells:
		var new_cell = Vector3(cell).rotated(Vector3i.UP,deg_to_rad(deg))
		new_cells.append(Vector3i(round(new_cell)))
	return new_cells

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

func get_available_cells(range,include_all : bool = false) -> Array[Vector3i]:
	var coords : Array[Vector3i] = []
	var range_size = range * 2 + 1
	
	if map == null:
		include_all = true
	
	var next_pass : Array[Vector3i] = [Vector3i.ZERO]
	for i in range:
		var fresh_next_pass : Array[Vector3i] = []
		
		while next_pass.size() > 0:
			var new_cell = next_pass.pop_front()
			
			if include_all or map.is_cell_free(new_cell * Vector3i(2,0,2), global_position) and !coords.has(new_cell):
				if include_all or !map.is_cell_occupied(new_cell * Vector3i(2,0,2), global_position) or new_cell == Vector3i.ZERO:
					coords.append(new_cell)
					
					fresh_next_pass.append(new_cell + Vector3i(1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(-1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(0,0,1))
					fresh_next_pass.append(new_cell + Vector3i(0,0,-1))
		
		next_pass.append_array(fresh_next_pass)
	
	return coords

func get_available_visible_cells(range):
	var coords = get_available_cells(range,true)
	
	var row_groups = arrange_into_rows(coords)
	
	for i in row_groups.size():
		var rows = row_groups[i]
		var slopes : Array[Vector3] = []
		match i:
			0:
				slopes.append_array([Vector3(1,0,-1),Vector3(1,0,1),Vector3(1,0,0)])
			1:
				slopes.append_array([Vector3(1,0,1),Vector3(-1,0,1),Vector3(0,0,1)])
			2:
				slopes.append_array([Vector3(-1,0,-1),Vector3(-1,0,1),Vector3(-1,0,0)])
			3:
				slopes.append_array([Vector3(1,0,-1),Vector3(-1,0,-1),Vector3(0,0,-1)])
		
		
		
		print(slopes)
	
	
	return coords

func arrange_into_rows(points: Array[Vector3i]) -> Array:
	var rows = [[[]],[[]],[[]],[[]]]
	
	while points.size() > 0:
		var point = points.pop_front()
		
		if point == Vector3i.ZERO:
			continue
		
		var index = 0
		var direction = Vector3i(round(Vector3.ZERO.direction_to(Vector3(point))))
		var direction_index = 0
		
		match direction:
			Vector3i.RIGHT:
				direction_index = 0
				index = abs(point.x) - 1
			Vector3i.BACK, Vector3i(1,0,1), Vector3i(-1,0,1):
				direction_index = 1
				index = abs(point.z) - 1
			Vector3i.LEFT:
				direction_index = 2
				index = abs(point.x) - 1
			Vector3i.FORWARD,  Vector3i(1,0,-1), Vector3i(-1,0,-1):
				direction_index = 3
				index = abs(point.z) - 1
		
		if !rows[direction_index].size() - 1 > index:
			rows[direction_index].append([])
		
		var tile : Tile
		if !map.is_cell_free(point * Vector3i(2,0,2),global_position) or map.is_cell_occupied(point * Vector3i(2,0,2),global_position):
			tile = Tile.new(point,true)
		else:
			tile = Tile.new(point)
		
		rows[direction_index][index].append(tile)
		
	return rows

func next_to_blacklist(cell,blacklist):
	var is_next_to = false
	
	if blacklist.has(cell + Vector3i(1,0,0)):
		is_next_to = true
	if blacklist.has(cell + Vector3i(-1,0,0)):
		is_next_to = true
	if blacklist.has(cell + Vector3i(0,0,1)):
		is_next_to = true
	if blacklist.has(cell + Vector3i(0,0,-1)):
		is_next_to = true
	
	print(is_next_to)
	return is_next_to
