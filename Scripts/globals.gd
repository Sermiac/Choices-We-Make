extends Node

var story_mode = true
var button_E_pressed = false
var story_end

# Almacenar la historia
var story_data = {}
var max_scene_conditions = 0
var transition


# DATA TO SAVE
var scene_number_House: int = 0
var scene_number_Bathroom: int = 0
var scene_name = ""


func _ready() -> void:
	pass

var player
var player_data = { # save player position dynamically (work in progress)
	"hold_position_House" = 0.0,
	"hold_position_Bathroom" = 0.0,
	"hold_flip" = false
}
func get_player_data(data: StringName):
	var node = player[0]
	var position_house = player_data["hold_position_House"]
	var position_bathroom = player_data["hold_position_Bathroom"]
	var flip = player_data["hold_flip"]
	if data == "position":
		if position_house == 0 or position_bathroom == 0:
			return
		if scene_name == "House":
			node.position.x = position_house
		if scene_name == "Bathroom":
			node.position.x = position_bathroom
	elif data == "flip":
		node.get_child(0).flip_h = flip


var interactables = {}
func initialize_scene_nodes(object = null, property_index = null):
	const interactable_properties_house = {
				# [.Visible, .Play_animation, .Collision disabled (optional)]
		"cellphone_1": [true, "cellphone_move"], 
		"cellphone_2": [true, "cellphone_move"],
		"cellphone_3": [true, "cellphone_move"],
		
		"bed_1": [false, "bed_move"],
		"bed_2": [true, "bed_move"],
		"bed_3": [false, "bed_idle"],
	}
	const interactable_properties_bathroom = {
		"gloryhole_1": [true, "gloryhole_move"],
		"gloryhole_2": [true, "gloryhole_move"],
	}
	
	
	const scenes = {
		"House" = interactable_properties_house,
		"Bathroom" = interactable_properties_bathroom,
	}
	var scene = scenes[scene_name]
	
	var node_key = object + "_" + str(get("scene_number_" + scene_name))
	var node = scene[node_key] if scene.has(node_key) else null
	if !node:
		node_key = object + "_" + "1" # Default to avoid error
		node = scene[node_key]
	if node.size() < property_index + 1:
		return
	var property = node[property_index]
	if property_index == 0:
		interactables[object].visible = property
		if node.size() < 3:
			interactables[object].get_child(0).disabled = not property
	if property_index == 1:
		interactables[object].get_child(2).play(property)
	if property_index == 2:
		interactables[object].get_child(0).disabled = property

# EDIT VARs TO CHANGE OR ADD STORY
var House_end = {}
var Bathroom_end = {}
var scenes_end = {
	"House": House_end,
	"Bathroom": Bathroom_end
	}
func story_number_manager(object_number = 0):
	var select_scene = scenes_end[scene_name]
	
	var number = get("scene_number_%s" % scene_name)
	var select_number = select_scene[number] if select_scene.has(number) else null
	if !select_number:
		print("***** End of story *****")
		story_end = true
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		
		return
	var select_array = select_number[object_number]
	return select_array
	

func get_current_scene(scene = null,number = null) -> StringName:
	var data = {
		"House": Globals.scene_number_House,
		"Bathroom": Globals.scene_number_Bathroom,
	}
	if scene and number:
		scene = Globals.scene_name
		number = data[scene]
		scene = scene + "_" + str(number)
		return scene
	elif scene:
		scene = Globals.scene_name
		return scene
	elif number:
		scene = Globals.scene_name
		number = data[scene]
		return str(number)
	else:
		return ""

# load story from text files
func load_story_file():
	var current_scene = get_current_scene("scene","number")
	var folder = "res://Assets/OriginalStory"
	if DirAccess.dir_exists_absolute(folder):
		pass
	else:
		folder = "res://Assets/Story"
		
	if current_scene:
		var file_path = "%s/Chapter_1/%s.txt" % [folder, get_current_scene("scene","number")]
		var file_access = FileAccess.open(file_path, FileAccess.READ)
		# Story lines
		var story = {}
		var index = 1
		var key = "text_"
		max_scene_conditions = null
		# Count Story lines
		var line_count = 0
		var story_number_temp = []
		var dict_end = scenes_end[scene_name]
		if file_access:
			file_access.seek(0) # Reset file cursor to the beginning
			while not file_access.eof_reached():
				var line = file_access.get_line()
				# Process each line of text
				if !line.contains("###") and line != "":
					story[key + str(index)] = line
					index += 1
					if line_count != null:
						line_count += 1
					if max_scene_conditions != null:
						max_scene_conditions += 1
				# When a blank space, updates the line count for object
				elif line == "" and line_count != null:
					story_number_temp += [line_count]
				# Updates lines to guide player
				elif line.to_lower() == "### optionaltext":
					line_count = null
					index += 99 - index
					max_scene_conditions = 0
				elif line.contains("###"):
					pass
				
			file_access.close()
			story_data[current_scene].merge(story)
			
			dict_end[get("scene_number_%s" % scene_name)] = story_number_temp
		else:
			print("Error: Could not open file at path: ", file_path)
			print("Error code: ", FileAccess.get_open_error())



# EDIT TO CHANGE OR ADD STORY
func story_manager(chapter_number, text_number) -> StringName:
	var CHAPTER_1 = story_data

	const CHAPTER_2 = {
		"text_1": "Este es el capítulo dos."
	}

	var chapters = {
		"chapter_1": CHAPTER_1,
		"chapter_2": CHAPTER_2
	}
	
	var scenes = {
		"House": scene_number_House,
		"Bathroom": scene_number_Bathroom
	}

	var chapter = chapters[str(chapter_number)]
	var scene = scenes[str(scene_name)]
	var select = chapter[str(scene_name) + "_" + str(scene)]
	if text_number == null or scene == null:
		return ""
	elif not select.has("text_" + str(text_number)):
		return ""
	else:
		return select["text_" + str(text_number)]

var save_temp
func save_on_file(number):
	# dictionary of data
	var save_data
	if number == 1:
		save_data = {
		"scene_number_House": Globals.scene_number_House,
		"scene_number_Bathroom": Globals.scene_number_Bathroom,
		}
		save_temp = save_data
		return
	if number == 2:
		save_data = {
		"scene_name": Globals.scene_name,
		"player_data": Globals.player_data
		}
	save_data.merge(save_temp)
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE) # Creates the save file
	save_file.store_string(JSON.stringify(save_data)) # Writes the data
	save_file.close()

func load_from_file():
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	print(ProjectSettings.globalize_path("user://savegame.json"))
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data:
		Globals.scene_number_House = data["scene_number_House"]
		Globals.scene_number_Bathroom = data["scene_number_Bathroom"]
		Globals.scene_name = data["scene_name"]
		for i in Globals.player_data:
			var play_data = data["player_data"]
			Globals.player_data[i] = play_data[i]

var dir = DirAccess.open("user://")
func delete_save():
	if dir.file_exists("savegame.json"):
		dir.remove("savegame.json")
		reset_all_global_data()

func reset_all_global_data():
	scene_number_House = 0
	scene_number_Bathroom = 0
	scene_name = ""
	story_end = false
	player_data = { # save player position dynamically (work in progress)
	"hold_position_House" = 0.0,
	"hold_position_Bathroom" = 0.0,
	"hold_flip" = false
	}
