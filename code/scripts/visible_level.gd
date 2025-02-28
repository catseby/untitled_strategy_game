extends Node3D


@export var group : String = "Hunters"
@onready var map = get_parent().get_node("Map")
@onready var preset_level = $Preset
@onready var visible_level = $Visible
@onready var seen_level = $Seen

var explored_cells = []
var visible_cells = []

func update_fog():
	visible_cells = []
	visible_level.clear()
	seen_level.clear()

	var units = get_tree().get_nodes_in_group(group)
	
	for unit in units:
		var gc = GridCalculator.new(unit.global_position,map)
		var temp_visible_cells = gc.get_available_visible_cells(unit.visibility_range)
		
		for cell in temp_visible_cells:
			if !explored_cells.has(cell):
				explored_cells.append(cell)
			if !visible_cells.has(cell):
				visible_cells.append(cell)

	for cell in explored_cells:
		var item = preset_level.get_cell_item(cell)
		if visible_cells.has(cell):
			visible_level.set_cell_item(cell,item)
		else:
			seen_level.set_cell_item(cell,item)
