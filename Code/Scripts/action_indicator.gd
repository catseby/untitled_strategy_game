extends GridMap

var GridCalculator = preload("res://Code/Scripts/grid_calculator.gd")

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

var current_index = INDEXES.BLUE
var current_skill
var current_aoe : Array[Vector3i] = []

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
	RED_BIG = 10}
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
	RED = 4}

var current_action
enum ACTION {
	MOVE,
	SKILL
}

func set_indicator(ind_position):
	ind_position = to_local(ind_position)
	var snap_position = local_to_map(ind_position)
	
	var indicator_position = Vector3i.ZERO
	indicator_position = map_to_local(snap_position)
	
	if get_cell_item(snap_position) != -1 and indicator_position != indicator.position:
		indicator.position = indicator_position
		
		clear_axis()
		set_axis(cell_default,current_index)
		
		if current_action == ACTION.MOVE:
			generate_path(snap_position)
			set_axis([local_to_map(Vector3i(indicator.position))],current_index + 5)
		else:
			var dir = Vector2(1,1).direction_to(Vector2(indicator.position.x,indicator.position.z))
			var angl = rad_to_deg(-dir.angle())
			
			var aoe : Array[Vector3i] = []
			var gc = GridCalculator.new()
			current_aoe.clear()
			
			for area in gc.get_rotated_cells(current_skill.AOE,angl):
				aoe.append(local_to_map(Vector3i(indicator.position)) + area)
				current_aoe.append(local_to_map(Vector3i(indicator.position)) + area)
			
			set_axis(aoe,current_index + 5)

func generate_path(end_position):
	final_path.clear()
	
	var gc = GridCalculator.new()
	var path = gc.get_new_path(get_used_cells(),active_unit,end_position)
	
	var pathV3 : Array[Vector3]
	for p in path:
		final_path.push_back(to_global(map_to_local(Vector3(p.x,0,p.y))))
		pathV3.push_back(Vector3(p.x,0,p.y))
	
	indicator_line.generate_line(pathV3,colors[COLORS.BLUE])

func action():
	if current_skill == null or current_skill.require_target:
		action_made.emit()
	match current_action:
		ACTION.MOVE:
			active_unit.move(final_path)
		ACTION.SKILL:
			var gc = GridCalculator.new(global_position,map)
			gc.apply_skill(current_skill,current_aoe)
			active_unit.skill()

			
	clear_indicators()

func confirm():
	action()

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
	current_action = null
	current_index = INDEXES.WHITE
	current_skill = null
	current_aoe = []

	
	clear_axis()

func highlight_indicators(unit):
	visible = true
	active_unit = unit
	set_axis([Vector3i(local_to_map(to_local(unit.global_position)))],6)

func movement_indicators(unit):
	clear_indicators()
	visible = true
	active_unit = unit #Maybe needs some cleanup
	current_action = ACTION.MOVE
	clear_axis()
	current_index = INDEXES.BLUE
	
	global_position = unit.global_position - Vector3(1,0,1)
	
	var gc = GridCalculator.new(global_position,map)
	var cells = gc.get_available_cells(unit.move_range)
	
	for cell in cells:
		if cell != Vector3i.ZERO:
			set_cell_item(cell,0,0)
	
	cell_default = cells
	set_axis(cells,2)

func skill_indicators(unit,skill):
	clear_indicators()
	visible = true
	active_unit = unit
	current_action = ACTION.SKILL
	clear_axis()
	current_index = skill.color
	current_skill = skill
	
	global_position = unit.global_position - Vector3(1,0,1)
	
	if skill.require_target:
		var gc = GridCalculator.new(global_position,map)
		var cells = gc.get_available_visible_cells(skill.range)
		
		for cell in cells:
			if cell != Vector3i.ZERO or skill.include_self:
				set_cell_item(cell,0,0)
		
		cell_default = cells
		set_axis(cells,current_index)
	
	else:
		var gc = GridCalculator.new(global_position,map)
		var cells = gc.get_aoe_cells(skill.range)
		
		cell_default = cells[0]
		current_aoe = cells[1]
		
		set_axis(cells[0],current_index)
		set_axis(cells[1],current_index + 5)
		
		print(current_aoe)

func set_axis(coords : Array[Vector3i] = [Vector3i.ZERO],index = 1):
	for i in coords.size():
		
		if !coords.has(coords[i] - Vector3i(0,0,-1)):
			axis.get_child(0).set_cell_item(coords[i],index,0)
		elif axis.get_child(0).get_cell_item(coords[i]) != index:
			axis.get_child(0).set_cell_item(coords[i],-1,0)
			
		if !coords.has(coords[i] - Vector3i(0,0,1)):
			axis.get_child(1).set_cell_item(coords[i],index,10)
		elif axis.get_child(1).get_cell_item(coords[i]) != index:
			axis.get_child(1).set_cell_item(coords[i],-1,0)
		
		if !coords.has(coords[i] - Vector3i(1,0,0)):
			axis.get_child(2).set_cell_item(coords[i],index,22)
		elif axis.get_child(2).get_cell_item(coords[i]) != index:
			axis.get_child(2).set_cell_item(coords[i],-1,0)
		
		if !coords.has(coords[i] - Vector3i(-1,0,0)):
			axis.get_child(3).set_cell_item(coords[i],index,16)
		elif axis.get_child(3).get_cell_item(coords[i]) != index:
			axis.get_child(3).set_cell_item(coords[i],-1,0)

func clear_axis():
	for i in axis.get_child_count():
		axis.get_child(i).clear()
