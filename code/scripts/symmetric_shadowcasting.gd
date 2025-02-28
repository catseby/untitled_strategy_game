extends Node

class Tile:
	var position: Vector2
	var is_wall: bool
	
	func _init(pos: Vector2, wall: bool):
		position = pos
		is_wall = wall

func get_visible_tiles(tiles: Array, light_source: Vector2) -> Array:
	var visible_tiles = []
	var walls = {} # Dictionary to store wall positions
	var tile_positions = {} # Dictionary to store tile positions
	
	# Store tile positions and walls for quick lookup
	for tile in tiles:
		tile_positions[tile.position] = tile
		if tile.is_wall:
			walls[tile.position] = true
	
	# Define directions (8-way for better coverage)
	var directions = [
		Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
		Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1),
		Vector2(2, 1), Vector2(2, -1), Vector2(-2, 1), Vector2(-2, -1),
		Vector2(1, 2), Vector2(-1, 2), Vector2(1, -2), Vector2(-1, -2)
	]
	
	# Perform raycasting from light source in each direction
	for dir in directions:
		var current_pos = light_source
		while current_pos in tile_positions:
			visible_tiles.append(current_pos)
			if current_pos in walls:
				break # Stop when hitting a wall
			current_pos += dir
	
	return visible_tiles
