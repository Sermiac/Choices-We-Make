extends Node

@onready var continue_button = $main_buttons/VBoxContainer/continue_button
@onready var confirmation_menu = $confirmation_menu
@onready var options_menu = $options_menu
@onready var label_story_end = $Label_story_end

func _ready():
	if Globals.story_end:
		label_story_end.visible = true
	if FileAccess.file_exists("user://savegame.json"):
		continue_button.set_disabled(false)
	else:
		continue_button.set_disabled(true)
	load_scenes_file()

func _on_continue_button_pressed() -> void:
	Globals.load_from_file()
	var scene
	if Globals.story_end:
		label_story_end.text = "Here you can change to \nwhatever scene you want... \n(not done yet)"
		return
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
		options_menu.visible = false
		label_story_end.visible = false

func _on_options_button_pressed() -> void:
	if options_menu.visible == false:
		options_menu.visible = true
		confirmation_menu.visible = false
		label_story_end.visible = false
	else:
		options_menu.visible = false

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func load_scenes_file():
	var folder = "res://Assets/OriginalStory"
	if DirAccess.dir_exists_absolute(folder):
		pass
	else:
		folder = "res://Assets/Story"

	var file_path = "%s/Chapter_1/Scenes.txt" % folder
	var file_access = FileAccess.open(file_path, FileAccess.READ)
	if file_access:
		file_access.seek(0) # Reset file cursor to the beginning
		while not file_access.eof_reached():
			var line = file_access.get_line()
			if line != "":
				add_scene(line)
				
		file_access.close()
	else:
		print("Error: Could not open file at path: ", file_path)
		print("Error code: ", FileAccess.get_open_error())


func add_scene(data: String):
	Globals.story_data[data] = {}
