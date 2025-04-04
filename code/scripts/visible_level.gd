extends Node3D


@export var group : String = "Hunters"
@export var fog_of_war : bool = true

@onready var map = get_parent().get_node("Map")
@onready var units = get_parent().get_node("Units")
@onready var preset_level = $Preset
@onready var visible_level = $Visible
@onready var seen_level = $Seen

var explored_cells : Dictionary[Vector3i, bool] = {}

func unit_moved(unit):
	if unit.group == group:
		update_fog()
	else:
		unit_visibility(unit)

func unit_visibility(unit):
	var unit_cell = preset_level.local_to_map(preset_level.to_local(unit.global_position))
	if visible_level.get_cell_item(unit_cell) == -1:
		unit.visible = false
	else:
		unit.visible = true

func update_fog():
	var ally_units = get_tree().get_nodes_in_group(group)
	
	for unit in ally_units:
		var gc = GridCalculator.new(unit.global_position,map)
		var visible_cells = gc.get_available_visible_cells(unit.visibility_range) + [Vector3i.ZERO]
		
		for cell_ in visible_cells:
			var cell = preset_level.local_to_map(preset_level.to_local(unit.global_position)) + cell_
			
			explored_cells[cell] = true
	
	for cell in explored_cells:
		var is_visible = explored_cells[cell]
		var item = preset_level.get_cell_item(cell)
		
		if is_visible and visible_level.get_cell_item(cell) == -1:
			visible_level.set_cell_item(cell,item)
			seen_level.set_cell_item(cell,-1)
		elif !is_visible and seen_level.get_cell_item(cell) == -1:
			visible_level.set_cell_item(cell,-1)
			seen_level.set_cell_item(cell,item)
		
		explored_cells[cell] = false
	
	for unit in units.get_children():
		if unit.group != group:
			unit_visibility(unit)
