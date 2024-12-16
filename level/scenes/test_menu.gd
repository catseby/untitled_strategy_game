extends Control



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level/scenes/1v1_elimination.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://level/scenes/2v_2_elimination.tscn")
