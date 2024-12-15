extends Node

var message : String = "Objective Message"
var complete : bool = false

signal update

func _ready() -> void:
	update.connect(get_parent().get_parent().update_objectives)

func update_objective():
	update.emit()

func get_objective():
	return message
