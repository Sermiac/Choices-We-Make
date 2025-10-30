extends Control

# el codigo de abajo son los botones
func _on_yes_pressed():
	Globals.delete_save()
	get_tree().change_scene_to_file("res://Scenes/cinematic1.tscn")


func _on_no_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
