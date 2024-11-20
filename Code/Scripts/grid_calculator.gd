extends Node

const SymetricShadowcasting = preload("res://Code/Scripts/symmetric_shadowcasting.gd")

var map : GridMap
var global_position : Vector3

class Tile:
	var position
	var type
	enum {
		Floor,
		Wall,
		Unit
	}
	var corner = Vector2(0,0.75)
	
	func _init(pos : Vector3i, new_type = Floor, vertical : bool = false) -> void:
		position = pos
		type = new_type
		if vertical:
			corner = Vector2(0.75,0)

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
	var tiles : Array[Tile]
	var rows = arrange_into_rows(coords,range)
	
	var SS = SymetricShadowcasting.new(rows)
	var visible_coords : Array[Vector3i] = SS.get_visible_tiles()
	visible_coords.append(Vector3i.ZERO)
	
	return visible_coords

func get_aoe_cells(range):
	var coords : Array[Vector3i] = get_available_cells(range,true)
	var units : Array[Vector3i] = []
	for coord in coords:
		if map.is_cell_occupied(coord * Vector3i(2,0,2), global_position):
			units.append(coord)
	
	print(coords)
	print(units)
	
	return [coords,units]


func arrange_into_rows(points: Array[Vector3i], row_count : int):
	var rows = []
	
	for j in row_count - 1:
		var empty_row : Array[Tile] = []
		rows.append(empty_row)
	
	while points.size() > 0:
		var point = points.pop_front()
		
		if point == Vector3i.ZERO:
			continue
		
		var index = 0
		var direction = Vector3i(round(Vector3.ZERO.direction_to(Vector3(point))))
		var vertical = false
		
		match direction:
			Vector3i.RIGHT:
				index = abs(point.x) - 1
			Vector3i.BACK, Vector3i(1,0,1), Vector3i(-1,0,1):
				vertical = true
				index = abs(point.z) - 1
			Vector3i.LEFT:
				index = abs(point.x) - 1
			Vector3i.FORWARD,  Vector3i(1,0,-1), Vector3i(-1,0,-1):
				vertical = true
				index = abs(point.z) - 1
		
		var tile : Tile
		if map.is_cell_occupied(point * Vector3i(2,0,2),global_position):
			tile = Tile.new(point, Tile.Unit, vertical)
		elif !map.is_cell_free(point * Vector3i(2,0,2),global_position):
			tile = Tile.new(point,Tile.Wall,vertical)
		else:
			tile = Tile.new(point,Tile.Floor,vertical)
		
		rows[index].append(tile)
	
	return rows
