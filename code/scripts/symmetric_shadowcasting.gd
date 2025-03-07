class_name SymmetricShadowcasting extends RefCounted

# Shadowcasting algorithm for visibility
func compute_fov(origin: Vector3i, radius: int, map_data: Dictionary) -> Array:
	var visible_tiles = []
	visible_tiles.append(origin)
	
	for quadrant in range(4):
		_cast_light(origin, radius, 1, 1.0, 0.0, quadrant, visible_tiles, map_data)
	
	return visible_tiles

func _cast_light(origin: Vector3i, radius: int, row: int, start_slope: float, end_slope: float, quadrant: int, visible_tiles: Array, map_data: Dictionary):
	if start_slope < end_slope:
		return
	
	var next_start_slope = start_slope
	for i in range(row, radius + 1):
		var blocked = false
		for dx in range(-i, i + 1):
			var dy = -i
			var transformed = _transform_quadrant(dx, dy, quadrant) + origin
			
			if transformed in map_data and map_data[transformed]:
				blocked = true
			else:
				visible_tiles.append(transformed)
				
			if blocked:
				next_start_slope = (dx - 0.5) / i
			else:
				if next_start_slope > end_slope:
					_cast_light(origin, radius, i + 1, next_start_slope, (dx + 0.5) / i, quadrant, visible_tiles, map_data)
				next_start_slope = (dx + 0.5) / i
		if blocked:
			break

func _transform_quadrant(dx: int, dy: int, quadrant: int) -> Vector3i:
	match quadrant:
		0: return Vector3i(dx,0,-dy)
		1: return Vector3i(dy,0,-dx)
		2: return Vector3i(dy,0,dx)
		3: return Vector3i(dx,0,dy)
	return Vector3i.ZERO
