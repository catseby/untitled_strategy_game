extends Node3D

const GridCalculator = preload("res://Code/Scripts/grid_calculator.gd")

const UNIT = preload("res://Level/Prefab/Units/human.tscn")

@onready var map = get_parent().get_parent().get_node("Map")

@export var units : Array[Node] = []
@export_enum("Hunters", "Guards") var team : String = "Hunters"

func queue_units(queue : Array[Node]) -> void:
	units.append_array(queue)
	return

func _init() -> void:
	visible = false

func add_units() -> void:
	push_error("ERROR: require add_units() function!")
