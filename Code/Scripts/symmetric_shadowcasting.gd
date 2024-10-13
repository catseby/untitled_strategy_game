extends Node

class Slope :
	var start : Vector2
	var end : Vector2
	
	func _init(new_start : Vector2 = Vector2.LEFT,new_end : Vector2 = Vector2.RIGHT) -> void:
		start = new_start
		end = new_end


var starter_slope : Slope
var slope_tangents : Array[Vector3]
var rows
var revealed_tiles : Array[Vector3i] = []

func _init(rows_new, new_slope_dir, slope_tangents_new):
	rows = rows_new
	starter_slope = Slope.new(new_slope_dir[0],new_slope_dir[1])
	slope_tangents = slope_tangents_new

func get_revealed_tiles():
	#for row in rows:
		#for tile in row:
			#print(tile.position)
	var slope = Slope.new()
	scan(slope)
	return revealed_tiles

func scan(slope) -> void:
	var prev_tile = null
	
	if !rows.is_empty():
		var row = rows.pop_front()
		
		for tile in row:
			
			if is_on_slope(tile,slope.end):
				return
			
			if !tile.is_wall and is_symetric(tile,slope):
				revealed_tiles.append(tile.position)
				#print("tile is wall")
			
			if prev_tile != null and prev_tile.is_wall and !tile.is_wall:
				slope.start = set_slope(tile)
				#print("prev is wall")
			
			if prev_tile != null and !prev_tile.is_wall and tile.is_wall:
				var next_slope = Slope.new(starter_slope.start)
				next_slope.end = set_slope(tile)
				scan(next_slope)
				#print("prev is floor")
			
			prev_tile = tile
		
		if !prev_tile.is_wall:
			scan(slope)
	
	#print(slope.start)
	return

func is_symetric(tile,slope) -> bool:
	var tile_slope = -Vector2.ZERO.direction_to(Vector2(tile.position.x,tile.position.z)).angle()
	
	if -slope.start.angle() < tile_slope and tile_slope < -slope.end.angle():
		return true
	return false

func set_slope(tile):
	var new_slope = Vector2.ZERO.direction_to(Vector2(tile.position.x,tile.position.z))
	
	return new_slope

func is_on_slope(tile,slope):
	var tile_slope = Vector2.ZERO.direction_to(Vector2(tile.position.x,tile.position.z))
	if tile_slope == slope:
		return true
	return false
