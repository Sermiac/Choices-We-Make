extends Node

@onready var continue_button = $main_buttons/VBoxContainer/continue_button
@onready var confirmation_menu = $confirmation_menu


func _ready():
	if FileAccess.file_exists("user://savegame.json"):
		continue_button.set_disabled(false)
	else:
		continue_button.set_disabled(true)

func _on_continue_button_pressed() -> void:
	Globals.load_from_file()
	var scene
	if Globals.scene_name == "House" or !Globals.scene_name:
		scene = "res://Scenes/house.tscn"
	elif Globals.scene_name == "Bathroom":
		scene = "res://Scenes/bathroom.tscn"
	get_tree().change_scene_to_file(scene)

func _on_new_button_pressed() -> void:
	if not FileAccess.file_exists("user://savegame.json"):
		get_tree().change_scene_to_file("res://Scenes/house.tscn")
	else:
		confirmation_menu.visible = true

func _on_options_button_pressed() -> void:
	var options = $options_menu
	if options.visible == false:
		options.visible = true
	else:
		options.visible = false

func _on_exit_button_pressed() -> void:
	get_tree().quit()
