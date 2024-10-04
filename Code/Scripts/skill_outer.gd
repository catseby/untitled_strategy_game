extends Node

@export var AOE : Array[Vector3i] = [Vector3i.ZERO]
@export var range : int = 1
@export var include_self : bool = false
@export var require_target : bool = false
@export var color = COLORS.RED

enum COLORS {
	WHITE = 0,
	BLUE = 1,
	GREEN = 2,
	ORANGE = 3,
	RED = 4
}

var skill : Node = null
