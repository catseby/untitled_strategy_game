extends Node

var slopes : Array[Vector3]
var slope_tangents : Array[Vector3]
var rows = []
var revealed_tiles : Array[Vector3i] = []

func _init(rows_new,slopes_new,slope_tangents_new):
	rows = rows_new
	slopes = slopes_new
	slope_tangents = slope_tangents_new

func get_revealed_tiles():
	scan()
	return revealed_tiles

func scan(depth : int = 0):
	var prev_tile = null
	if rows.size() > depth:
		for tile in rows[depth]:
			#print(tile.position)
			if tile.is_wall or is_symetric(tile):
				revealed_tiles.append(tile.position)
				#print("tile is wall")
			
			if prev_tile != null and prev_tile.is_wall and !tile.is_wall:
				start_slope(tile,1)
				print("prev is wall")
			
			if prev_tile != null and !prev_tile.is_wall and tile.is_wall:
				start_slope(tile,0)
				scan(depth + 1)
				print("prev is floor")
			
			prev_tile = tile
		
		if prev_tile != null and prev_tile.is_wall:
			scan(depth + 1)
	
	return

func is_symetric(tile):
	#print(slopes.has(Vector3.ZERO.direction_to(Vector3(tile.position))))
	#print(Vector3.ZERO.direction_to(Vector3(tile.position)))
	#print(slopes)
	return slopes.has(Vector3.ZERO.direction_to(Vector3(tile.position)))

func start_slope(tile,index):
	slopes.append(Vector3.ZERO.direction_to(Vector3(tile.position) + slope_tangents[index]))
