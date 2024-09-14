extends Node3D

const PCU = preload("res://Level/Prefab/player_controlled_unit.tscn")

@export var units : Array[Node] = []
@export var map : GridMap

func queue_units(queue : Array[Node]) -> void:
	units.append_array(queue)
	return

func _init() -> void:
	visible = false


func _ready() -> void:
	var pcu = PCU.instantiate()
	queue_units([pcu])

func add_units() -> void:
	for i in units.size():
		units[i].global_position = get_child(i).global_position
		get_parent().add_child(units[i])
