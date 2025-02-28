extends GridMap

@export var turn_order : Node

func is_cell_free(coords : Vector3i, map_position : Vector3) -> bool:
	var free = false
	var bpos = map_position
	var pos = global_position - bpos

	var tc = coords - Vector3i(pos)
	tc = local_to_map(to_local(Vector3i(tc)))

	var index = get_cell_item(tc)

	if index != -1:
		free = true

	return free

func is_cell_occupied(coords : Vector3i, map_position : Vector3 = Vector3.ZERO) -> bool:
	var occupied = false
	var bpos = map_position
	var pos = global_position - bpos

	var tc = coords - Vector3i(pos)
	tc = local_to_map(to_local(Vector3i(tc)))

	for child in turn_order.get_children():
		var c_pos = local_to_map(to_local(Vector3i(child.global_position)))

		if c_pos == tc:
			occupied = true
			break

	return occupied

func get_unit(coords : Vector3i, map_position : Vector3 = Vector3.ZERO) -> Node3D:
	var unit = null
	var bpos = map_position
	var pos = global_position - bpos

	var tc = coords - Vector3i(pos)
	tc = local_to_map(to_local(Vector3i(tc)))

	for child in turn_order.get_children():
		var c_pos = local_to_map(to_local(Vector3i(child.global_position)))

		if c_pos == tc:
			unit = child
			break

	return unit
