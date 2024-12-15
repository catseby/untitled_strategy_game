extends Node3D

const GridCalculator = preload("res://code/scripts/grid_calculator.gd")

const UNIT = preload("res://level/prefab/units/human.tscn")

@onready var map = get_parent().get_parent().get_node("Map")

enum TEAMS{
	Hunters,
	Guards
}
@export var units : Array[Node] = []
@export var friendly_team : TEAMS = 0
@onready var team : String = TEAMS.keys()[friendly_team]

func queue_units(queue : Array[Node]) -> void:
	units.append_array(queue)
	return

func _init() -> void:
	visible = false

func add_units() -> void:
	push_error("ERROR: require add_units() function!")
