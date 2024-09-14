extends Node3D

const PCU = preload("res://Level/Prefab/player_controlled_unit.tscn")

@export var units : Array[Node] = []
@export var map : GridMap
@export var action_indicator : Node3D

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
		get_parent().add_child(units[i])
		units[i].global_position = get_child(i).global_position
		units[i].show_indicators.connect(action_indicator.show_indicators)
