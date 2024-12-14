extends Node

var rows
var blind_spots = []
var visible_tiles : Array[Vector3i] = []

func _init(rows) -> void:
	for row in rows:
		for tile in row:
			
			if tile.type == tile.Wall and tile_visible(tile):
				set_blind_spot(tile)
			elif tile_visible(tile):
				visible_tiles.append(tile.position)
				if tile.type == tile.Unit:
					set_blind_spot(tile)


func get_visible_tiles():
	return visible_tiles

func set_blind_spot(tile):
	var d1 = Vector2.ZERO.direction_to(Vector2(tile.position.x,tile.position.z) + tile.corner)
	var d2 = Vector2.ZERO.direction_to(Vector2(tile.position.x,tile.position.z) - tile.corner)
	
	blind_spots.append([d1,d2])


func tile_visible(tile):
	for spot in blind_spots:
		var deg = Vector2.ZERO.direction_to(Vector2(tile.position.x,tile.position.z))
		
		if spot[0].distance_to(deg) < spot[0].distance_to(spot[1]) and spot[1].distance_to(deg) < spot[1].distance_to(spot[0]):
			return false
	
	return true
