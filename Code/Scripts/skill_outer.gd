extends Node

@export var AOE : Array[Vector3i] = [Vector3i.ZERO]
@export var range : int = 1
@export var include_self : bool = false
@export var require_target : bool = false

var skill : Node = null
