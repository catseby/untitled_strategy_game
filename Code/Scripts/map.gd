extends GridMap

func is_cell_free(coords : Vector3i, map_position : Vector3) -> bool:
	var free = false
	
	var bpos = map_position
	
	var pos = global_position - bpos
	
	var tc = coords - Vector3i(pos)
	
	tc = to_local(tc)
	tc = Vector3i(local_to_map(Vector3i(tc)))
	var index = get_cell_item(tc)
	
	if index != -1:
		free = true
	
	return free
