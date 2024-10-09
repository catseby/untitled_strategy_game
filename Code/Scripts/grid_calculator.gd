extends Node

var map : GridMap
var global_position : Vector3

func _init(new_global_position : Vector3 = Vector3.ZERO, new_map : GridMap = null) -> void:
	map = new_map
	global_position = new_global_position

#func get_skill_angle(pos : Vector3 = Vector3.ZERO,skill_aoe : Array[Vector3i] = [Vector3i.ZERO]):
	#var dir = Vector2(1,1).direction_to(Vector2(pos.x,pos.z))
	#var angl = rad_to_deg(-dir.angle())
	#
	#var aoe : Array[Vector3i] = []
	#for area in get_rotated_cells(skill_aoe,angl):
		#aoe.append(local_to_map(Vector3i(pos)) + area)
	#
#
#func get_rotated_cells(cells,deg) -> Array[Vector3i]:
	#var new_cells : Array[Vector3i] = []
	#for cell in cells:
		#var new_cell = Vector3(cell).rotated(Vector3i.UP,deg_to_rad(deg))
		#new_cells.append(Vector3i(new_cell))
	#return new_cells

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

func get_available_cells(range) -> Array[Vector3i]:
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

func get_available_visible_cells(range):
	var coords = get_available_cells(range)
	
	var rows = arrange_into_rows(coords)
	var arr : Array[Vector3i] = []
	arr.append_array(rows[1][3])
	
	return arr

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
		
		print(index)
		print(direction)
		
		rows[direction_index][index].append(Vector3i(point))
		
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
