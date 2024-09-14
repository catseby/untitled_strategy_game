extends Node3D

@onready var player_spawn = $Player_Spawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_spawn.add_units()
