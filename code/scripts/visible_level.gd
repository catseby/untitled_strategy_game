extends Node3D


@export var group : String = "Hunters"

@onready var map = get_parent().get_node("Map")
@onready var units = get_parent().get_node("Units")
@onready var preset_level = $Preset
@onready var visible_level = $Visible
@onready var seen_level = $Seen

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
	var visible_cells = []
	var explored_cells = seen_level.get_used_cells() + visible_level.get_used_cells()

	var ally_units = get_tree().get_nodes_in_group(group)
	
	for unit in ally_units:
		var gc = GridCalculator.new(unit.global_position,map)
		var temp_visible_cells = gc.get_available_visible_cells(unit.visibility_range)
		
		for cell_ in temp_visible_cells:
			var cell = preset_level.local_to_map(preset_level.to_local(unit.global_position)) + cell_
			
			if !visible_cells.has(cell):
				visible_cells.append(cell)
				
				if visible_level.get_cell_item(cell) == -1:
					var item = preset_level.get_cell_item(cell)
					visible_level.set_cell_item(cell, item)
					
					if seen_level.get_cell_item(cell) != -1:
						seen_level.set_cell_item(cell, -1)
	
	
	explored_cells = explored_cells.filter(func(cell): return not visible_cells.has(cell))
	for cell in explored_cells:
		if seen_level.get_cell_item(cell) == -1:
			var item = preset_level.get_cell_item(cell)
			seen_level.set_cell_item(cell,item)
	
	for unit in units.get_children():
		if unit.group != group:
			unit_visibility(unit)
