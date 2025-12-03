extends Node

var story_mode = true
var button_E_pressed = false
var story_end = false

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

# Gives properties to nodes in the scene based on the load data
# If there are textlines in the node, it will be visible and will have anim
var interactables = {}
func initialize_scene_nodes(object = null, property_index = null):
	var current_scene = get_current_scene(true,true)
	var scene = story_data[current_scene] if story_data.has(current_scene) else null
	if !scene:
		it_is_the_end()
		return
	var node_key = scene[object] if scene.has(object) else null
	var node = node_key["properties"] if node_key else null
	if !node:
		var anim = "%s_idle" % object
		node = [false, anim]
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

# create the scene objs
func list_scene_objs():
	var scene_objs = ["firstlines","optionaltext"]
	for node in interactables:
		scene_objs += [node]
	return scene_objs

# check if it is in the scene objs, works with list_scene_objs()
# Used to attach dynamically textlines and properties in load_from_file()
func is_in_scene_objs(obj, scene_objs):
	for i in scene_objs:
		if obj.containsn(i):
			return i
	return null
	

# Check if it is the end of story
func it_is_the_end():
	print("***** End of story *****")
	story_end = true
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


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
# Creates objects with textlines, properties and add max conditions to change scene
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
		var index = 0
		var key = "text_"
		var mode
		var scene_objs = list_scene_objs()
		max_scene_conditions = 0
		if file_access:
			file_access.seek(0) # Reset file cursor to the beginning
			while not file_access.eof_reached():
				var line = file_access.get_line()
				# Process each line of text
				if line == "":
					mode = null
					index = 0
				
				if line.containsn("###"):
					mode = is_in_scene_objs(line, scene_objs)
					
				if !line.containsn("###"):
					if mode != null:
						index += 1
						var txtLns = "textLines"
						var anim = "%s_move" % mode
						if mode not in story:
							story[mode] = {}
							story[mode][txtLns] = {}
							if mode != "firstlines" and mode != "optionaltext":
								story[mode]["properties"] = [true, anim]
								max_scene_conditions += 1
						if index != 0:
							story[mode][txtLns].merge({key + str(index) : line})
				
			file_access.close()
			story_data[current_scene].merge(story)
		else:
			print("Error: Could not open file at path: ", file_path)
			print("Error code: ", FileAccess.get_open_error())



# Manages story_data dict created from files
func story_manager(text_number, object) -> StringName:
	# There is no system to manage different chapters yet (work in progress)
	var CHAPTER_1 = story_data

	var scene = get_current_scene(true, true)
	var scene_data = CHAPTER_1[scene]
	var obj = scene_data[object]
	var select = obj["textLines"]
	if text_number == null or scene == null:
		return ""
	elif not select.has("text_" + str(text_number)):
		return ""
	else:
		return select["text_" + str(text_number)]
		


# ------------- Functions to edit data
# Saves in two steps
# 1 when scene has not loaded (saves current scene)
# 2 when scene has loaded (saves player data and last scene)
var save_temp
func save_on_file(number: int):
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

# Resets player and scenes data
func reset_all_global_data():
	scene_number_House = 0
	scene_number_Bathroom = 0
	scene_name = ""
	story_end = false
	player_data = { # save player position dynamically
	"hold_position_House" = 0.0,
	"hold_position_Bathroom" = 0.0,
	"hold_flip" = false
	}
# --------------- End
