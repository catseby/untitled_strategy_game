extends Node
class_name GridCalculator
## Calculates all kinds of possible interactions in the current map.

const SymetricShadowcasting = preload("res://code/scripts/symmetric_shadowcasting.gd")

var map : GridMap ## Current map.
var global_position : Vector3 ## Calculation position.

#class Tile: ## Class for calculating symetric shadowcasting.
	#var position : Vector3i
	#var type
	#enum {
		#FLOOR,
		#WALL,
		#UNIT
	#}
	#var corner = Vector2(0,0.75)
#
	#func _init(pos : Vector3i, new_type = FLOOR, vertical : bool = false) -> void:
		#position = pos
		#type = new_type
		#if vertical:
			#corner = Vector2(0.75,0)

func _init(_global_position : Vector3 = Vector3.ZERO, _map : GridMap = null) -> void:
	map = _map
	global_position = _global_position

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

## Return all the given cells within a certain range, depending on the GridCalculator global_position.
## include_all - If True, will ignore walls.
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


## Just like the get_available_cells() function, except it also calculates if the cell is, or isn't infront of a wall.
func get_available_visible_cells(range : int):
	
	var coords : Array[Vector3i] = []
	var quadrants : Array[Array] = [[],[],[],[]]
	var tiles : Dictionary = {}
	var range_size = range * 2 + 1
	
	var next_pass : Array[Vector3i] = [Vector3i.ZERO]
	for i in range:
		var fresh_next_pass : Array[Vector3i] = []
		#var fresh_row : Array[Tile] = []
		
		for rows in quadrants:
			rows.append({})

		while next_pass.size() > 0:
			var new_cell = next_pass.pop_front()

			#var occupied = map.is_cell_occupied(new_cell * Vector3i(2,0,2), global_position)
			var free = map.is_cell_free(new_cell * Vector3i(2,0,2), global_position)

			if !coords.has(new_cell):
				coords.append(new_cell)

				fresh_next_pass.append(new_cell + Vector3i(-1,0,0))
				fresh_next_pass.append(new_cell + Vector3i(0,0,1))
				fresh_next_pass.append(new_cell + Vector3i(1,0,0))
				fresh_next_pass.append(new_cell + Vector3i(0,0,-1))
				
				
				var tile = Vector2(new_cell.x,new_cell.z)
				
				
				#if !free:
					#tiles[tile] = true
				#else:
					#tiles[tile] = false
				
				var dir = Vector2.ZERO.direction_to(tile).normalized()
				
				if dir.x <= -0.6: #West
					quadrants[0][i][tile] = !free #i represents row
				if dir.y <= -0.6: #North
					quadrants[1][i][tile] = !free
				if dir.x >= 0.6: #East
					quadrants[2][i][tile] = !free
				if dir.y >= 0.6: #South
					quadrants[3][i][tile] = !free
		
		#rows.append(fresh_row)
		next_pass = fresh_next_pass
	
	var visible_tiles : Array[Vector3i] = []
	
	for i in quadrants.size() - 2:
		var rows = quadrants[i]
		visible_tiles.append_array(scan(rows, 1, i))
	
	print(visible_tiles)
	
	return visible_tiles

func scan(rows, depth, quadrant) -> Array[Vector3i]:
	
	var visible_tiles : Array[Vector3i] = []
	
	var row = rows[depth]
	for tile in row:
		visible_tiles.append(Vector3i(tile.x, 0, tile.y))
	
	print(visible_tiles)
	
	if rows.size() - 1 > depth:
		visible_tiles.append_array(scan(rows, depth + 1, quadrant)) 
	
	return visible_tiles

	#for tile in tiles:
		#print(tiles[tile])
	#var visible_tiles : Array[Vector3i] = compute_fov(tiles,Vector3i.ZERO, 15)
	#print(visible_tiles)
#
#
	#return visible_tiles
#
#func compute_fov(is_blocking, mark_visible):
	#var origin = Vector2.ZERO
	#mark_visible(origin)
	#
	#for i in range(4):
		#var quadrant = Quadrant.new(i, origin)
#
		#var reveal = func(tile):
			#var pos = quadrant.transform(tile)
			#mark_visible(pos)
		#
		#var is_wall 
		

## Returns all cells with a unit in them, within the given range.
## Returns in form of an array [Coordinates, Units].
## Coordinates are the positions, tiles with units in them.
## Units are the unit nodes themselves.
func get_aoe_cells(range):
	var coords : Array[Vector3i] = []
	var units : Array[Vector3i] = []
	for coord in coords:
		if map.is_cell_occupied(coord * Vector3i(2,0,2), global_position) and !units.has(coord):
			units.append(coord)

	return [coords,units]
