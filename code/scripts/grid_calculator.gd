extends Node
class_name GridCalculator
## Calculates all kinds of possible interactions in the current map.

const SymetricShadowcasting = preload("res://code/scripts/symmetric_shadowcasting.gd")

var map : GridMap ## Current map.
var global_position : Vector3 ## Calculation position.

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
	
	var visible_cells : Array[Vector3i] = [Vector3i.ZERO]
	
	for quad in range(4):
		visible_cells.append_array(scan(
			Row.new(1, Fraction.new(1,-1), Fraction.new(1,1), -(range/2) + 2),
			Quadrant.new(quad),
			range - 1
		))
	
	return visible_cells


func scan(row : Row,quadrant : Quadrant, range : int):
	
	if row.depth > range:
		return []
	
	var visible_cells : Array[Vector3i] = []
	
	var prev_cell : Vector3i
	for tile in row.tiles():
		var cell : Vector3i = quadrant.transform(tile)
		
		if is_free(cell) and  is_symetric(row, tile) and in_distance(cell, range):
			visible_cells.append(cell)
		if not is_free(prev_cell) and is_free(cell):
			row.start_slope = slope(tile)
		if is_free(prev_cell) and not is_free(cell):
			var next_row = row.next()
			next_row.end_slope = slope(tile)
			visible_cells.append_array(scan(next_row, quadrant, range))
		
		prev_cell = cell
	
	if is_free(prev_cell):
		visible_cells.append_array(scan(row.next(), quadrant, range))
	
	return visible_cells

func is_free(cell : Vector3i) -> bool:
	if cell == null:
		return false
	return map.is_cell_free(cell * Vector3i(2,0,2), global_position)

func slope(tile : Vector2i) -> Fraction:
	var row_depth = tile.x
	var col = tile.y
	return Fraction.new((2 * col - 1), (2 * row_depth))

func is_symetric(row : Row, tile : Vector2i) -> bool:
	var col = tile.y
	return (col >= row.depth * row.start_slope.toFloat()
			and col <= row.depth * row.end_slope.toFloat())

func in_distance(cell : Vector3i, range : int):
	return abs(cell.x) + abs(cell.z) <= range

class Row:
	
	var depth : int
	var falloff : int
	var start_slope : Fraction
	var end_slope : Fraction
	
	func _init(_depth, _start_slope, _end_slope, _falloff) -> void:
		depth = _depth
		start_slope = _start_slope
		end_slope = _end_slope
		falloff = _falloff
		
		print("f" + str(falloff))
	
	func next() -> Row:
		return Row.new(depth + 1, start_slope, end_slope, falloff + 1)
	
	func tiles() -> Array[Vector2i]:
		var tileArr : Array[Vector2i] = []
		
		var min_col = round_ties_up(depth * start_slope.toFloat())
		var max_col = round_ties_down(depth * end_slope.toFloat())
		
		for col in range(min_col, max_col + 2):
			tileArr.append(Vector2i(depth,col))
		
		return tileArr
	
	func round_ties_up(n : float) -> float:
		return floor(n + 0.5)
	
	func round_ties_down(n : float) -> float:
		return floor(n - 0.5)

class Quadrant:
	
	var cardinal : int
	
	func _init(_cardinal : int) -> void:
		cardinal = _cardinal
	
	func transform(tile):
		var row = tile.x
		var col = tile.y
		match cardinal:
			0: #North
				return Vector3i(col,0,-row)
			1: #South
				return Vector3i(col,0,row)
			2: #East
				return Vector3i(row,0,col)
			3: #West
				return Vector3i(-row,0,col)

class Fraction:
	var x : float
	var y : float
	
	func _init(_x : float, _y : float):
		x = _x
		y = _y
	
	func toFloat() -> float:
		return x / y

## Returns all cells with a unit in them, within the given range.
## Returns in form of an array [Coordinates, Units].
## Coordinates are the positions, tiles with units in them.
## Units are the unit nodes themselves.
func get_aoe_cells(range):
	var coords : Array[Vector3i] = get_available_cells(range, true)
	var units : Array[Vector3i] = []
	for coord in coords:
		if map.is_cell_occupied(coord * Vector3i(2,0,2), global_position) and !units.has(coord):
			units.append(coord)

	return [coords,units]
