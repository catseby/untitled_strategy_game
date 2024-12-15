extends "res://code/scripts/objectives/objective.gd"

@export_enum("Hunters","Guards") var eliminate : String = "Hunters"

var target_count = -1

func _ready() -> void:
	get_parent().get_parent().get_node("Units").child_exiting_tree.connect(update_objective)
	update.connect(get_parent().get_parent().update_objectives)

func get_objective():
	if target_count == -1:
		target_count = get_tree().get_node_count_in_group(eliminate)
	
	var targets_left = target_count - get_tree().get_node_count_in_group(eliminate)
	message = "Eliminate " + eliminate.to_lower() + ": " + str(targets_left) + " / " + str(target_count)
	if targets_left >= target_count:
		complete = true
		message += " (Complete)"
	return message
