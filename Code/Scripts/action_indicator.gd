extends GridMap

@onready var axis = $Axis
@onready var indicator = $Indicator
@onready var active_unit : Node3D
@onready var indicator_line = $Indicator_Line

@export var map : GridMap
@export var ui : Control
var cell_default

var final_path : Array[Vector3] = []

signal move(move_position)
signal action_made

enum INDEXES {
	WHITE = 1,
	WHITE_BIG = 6,
	BLUE = 2,
	BLUE_BIG = 7,
	GREEN = 3,
	GREEN_BIG = 8,
	ORANGE = 4,
	ORANGE_BIG = 9,
	RED = 5,
	RED_BIG = 10
}

var colors = [
	Color.WHITE,
	Color("00b4ff"),
	Color("00b400"),
	Color("ffb400"),
	Color("ff0000")
	]


enum COLORS {
	WHITE = 0,
	BLUE = 1,
	GREEN = 2,
	ORANGE = 3,
	RED = 4
}



func set_indicator(ind_position):
	ind_position = to_local(ind_position)
	var snap_position = local_to_map(ind_position)
	
	var indicator_position = Vector3i.ZERO
	indicator_position = map_to_local(snap_position)
	
	if get_cell_item(snap_position) != -1 and indicator_position != indicator.position:
		indicator.position = indicator_position
		
		clear_axis()
		set_axis(cell_default,2)
		set_axis([local_to_map(Vector3i(indicator.position))],7)
		
		generate_path(snap_position)

func generate_path(end_position):
	var cells = get_used_cells()
	final_path.clear()
	
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
	
	var pathV3 : Array[Vector3]
	for p in path:
		final_path.push_back(to_global(map_to_local(Vector3(p.x,0,p.y))))
		pathV3.push_back(Vector3(p.x,0,p.y))
	
	indicator_line.generate_line(pathV3,colors[COLORS.BLUE])

func action():
	action_made.emit()
	active_unit.move(final_path)
	clear_indicators()

func cancel():
	clear_indicators()

#OUTLINES

func clear_indicators():
	visible = false
	indicator.position = Vector3(1,0,1)
	indicator_line.mesh = null
	clear()
	active_unit = null
	cell_default = null
	
	clear_axis()

func highlight_indicators(unit):
	visible = true
	active_unit = unit
	set_axis([Vector3i(local_to_map(to_local(unit.global_position)))],6)

func movement_indicators(unit):
	visible = true
	active_unit = unit #Maybe needs some cleanup
	clear_axis()
	
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
				if !map.is_cell_occupied(new_cell * Vector3i(2,0,2), global_position):
					coords.append(new_cell)
					set_cell_item(new_cell,0,0)
					
					fresh_next_pass.append(new_cell + Vector3i(1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(-1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(0,0,1))
					fresh_next_pass.append(new_cell + Vector3i(0,0,-1))
					
				elif new_cell == Vector3i.ZERO:
					coords.append(new_cell)
					
					fresh_next_pass.append(new_cell + Vector3i(1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(-1,0,0))
					fresh_next_pass.append(new_cell + Vector3i(0,0,1))
					fresh_next_pass.append(new_cell + Vector3i(0,0,-1))
		
		next_pass.append_array(fresh_next_pass)
	
	cell_default = coords
	set_axis(coords,2)

func set_axis(coords : Array[Vector3i] = [Vector3i.ZERO],index = 1):
	for i in coords.size():
		if !coords.has(coords[i] - Vector3i(0,0,-1)):
			axis.get_child(0).set_cell_item(coords[i],index,0)
		
		if !coords.has(coords[i] - Vector3i(0,0,1)):
			axis.get_child(1).set_cell_item(coords[i],index,10)
		
		if !coords.has(coords[i] - Vector3i(1,0,0)):
			axis.get_child(2).set_cell_item(coords[i],index,22)
		
		if !coords.has(coords[i] - Vector3i(-1,0,0)):
			axis.get_child(3).set_cell_item(coords[i],index,16)

func clear_axis():
	for i in axis.get_child_count():
		axis.get_child(i).clear()
