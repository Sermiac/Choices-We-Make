extends Node




func _on_yes_button_pressed() -> void:
	Globals.delete_save()
	get_tree().change_scene_to_file("res://Scenes/house.tscn")


func _on_no_button_pressed() -> void:
	self.visible = false
