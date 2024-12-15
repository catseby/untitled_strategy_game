extends Node

@export_multiline var message : String = "Objective Message"
var complete : bool = false
@onready var level = get_parent().get_parent()

signal update

func _ready() -> void:
	update.connect(level.update_objectives)

func update_objective(node):
	update.emit()

func get_objective():
	return message
