extends Node

var story_mode = true
var button_E_pressed = false


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
				# [.Collision disabled, .Play_animation, .Visible]
		"cellphone_1": [false, "cellphone_move", true], 
		"cellphone_2": [false, "cellphone_move", true],
		"cellphone_3": [true, "cellphone_idle", true],
		
		"bed_1": [true, "bed_move", false],
		"bed_2": [false, "bed_move", true],
		"bed_3": [true, "bed_idle", false],
	}
	const interactable_properties_bathroom = {
		"gloryhole_1": [false, "gloryhole_move", true],
	}
	
	
	const scenes = {
		"House" = interactable_properties_house,
		"Bathroom" = interactable_properties_bathroom,
	}
	var scene = scenes[scene_name]
	var node = scene[object + "_" + str(get("scene_number_" + scene_name))]
	var property = node[property_index]
	if property_index == 0:
		interactables[object].get_child(0).disabled = property
	if property_index == 1:
		interactables[object].get_child(2).play(property)
	if property_index == 2:
		interactables[object].visible = property

# EDIT TO CHANGE OR ADD STORY
func story_number_manager(object_number = 0):
	const House_end = { # change the value inside to set final line of dialogue
		# The index is the scene
		1: [2,8],
		2: [3,7,9],  # [First dialogues, cellphone dialogues, bed dialogues]
		3: [3]
	}
	const Bathroom_end = {
		1: [2,5],  # [First dialogues, gloryhole dialogues]
		2: [0],
	}
	const scene_end = {
	"House": House_end,
	"Bathroom": Bathroom_end
	}
	var select_scene = scene_end[scene_name]
	var select_number = select_scene[get("scene_number_%s" % scene_name)]
	var select_array = select_number[object_number]
	return select_array
	

# EDIT TO CHANGE OR ADD STORY
func story_manager(chapter_number, text_number) -> StringName:
	const House_1 = {
		"text_1": "[b]Julia:[/b]   Someone is calling me.",
		"text_2": "[b]Julia:[/b]   My phone is in my bedroom...",
	
		"text_3": "[b]Julia:[/b]   Hey Lisa, what's up?",
		"text_4": "[b]Lisa:[/b]   Hey, I have a plan for today, are you up for it?",
		"text_5": "[b]Julia:[/b]   I don't know, I am short on money",
		"text_6": "[b]Lisa:[/b]   If you need money, I can help you with that...",
		"text_7": "[b]Lisa:[/b]   I have a way, meet me at the universtiy's bathroom",
		"text_8": "[b]Julia:[/b]   *What is she up to? well, I have nothing to lose*",
		# Optional text lines
		"text_99": "[b]Julia:[/b]   *I need to check my phone first...*",
		}

	const Bathroom_1 = {
		"text_1": "[b]Julia:[/b]   I don't know... I shouldn't be doing this",
		"text_2": "[b]Julia:[/b]   I'm going to check, just out of curiosity...",

		"text_3": "[b]Julia:[/b]   *stares...",
		"text_4": "[b]Julia:[/b]   What am I doing??",
		"text_5": "[b]Julia:[/b]   Fuck this shit, I'm out of here!",
		# Optional text lines
		"text_99": "[b]Julia:[/b]   *I am a little curious. I cannot leave like that*",
	}

	const House_2 = {
		"text_1": "[b]Julia:[/b]   I gotta call Lisa again",
		"text_2": "[b]Julia:[/b]   This was not a good idea",
		"text_3": "[b]Julia:[/b]   What was she thinking??...",

		"text_4": "[b]Julia:[/b]   WTF!",
		"text_5": "[b]Julia:[/b]   ARE YOU ON DRUGS??",
		"text_6": "[b]Lisa:[/b]   No...",
		"text_7": "[b]Julia:[/b]   *I will just sleep... I need to think...*",

		"text_8": "[b]Julia:[/b]   I need the money, but do I want to do that?",
		"text_9": "[b]Julia:[/b]   Is it the only way?...",
		
		"text_99": "[b]Julia:[/b]   I need to call Lisa!!",
		"text_100": "[b]Julia:[/b]   I need to think about all of this... Just a nap its all I need...",
		}
		
	const House_3 = {
		"text_1": "[b]Julia:[/b]   I need money!!",
		"text_2": "[b]Julia:[/b]   Fuck this shit!!",
		"text_3": "[b]Julia:[/b]   AGHHH",

		"text_4": "[b]Julia:[/b]   WTF!",
		"text_5": "[b]Julia:[/b]   ARE YOU ON DRUGS??",
		"text_6": "[b]Lisa:[/b]   No...",
		"text_7": "[b]Julia:[/b]   *I will just sleep... I need to think...*",

		"text_8": "[b]Julia:[/b]   I need the money, but do I want to do that?",
		"text_9": "[b]Julia:[/b]   Is it the only way?...",
		
		"text_99": "[b]Julia:[/b]   I need to call Lisa!!",
		}

	const CHAPTER_1 = {
		"House_1" = House_1,
		"House_2" = House_2,
		"House_3" = House_3,
		"Bathroom_1" = Bathroom_1,
	}



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

var temp
func save_on_file(number):
	# dictionary of data
	var save_data
	if number == 1:
		save_data = {
		"scene_number_House": Globals.scene_number_House,
		"scene_number_Bathroom": Globals.scene_number_Bathroom,
		}
		temp = save_data
		return
	if number == 2:
		save_data = {
		"scene_name": Globals.scene_name,
		}
	save_data.merge(temp)
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE) # Creates the save file
	save_file.store_string(JSON.stringify(save_data)) # Writes the data
	#print(ProjectSettings.globalize_path("user://savegame.json")) # Debug to print save location
	save_file.close()

func load_from_file():
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data:
		Globals.scene_number_House = data["scene_number_House"]
		Globals.scene_number_Bathroom = data["scene_number_Bathroom"]
		Globals.scene_name = data["scene_name"]

var dir = DirAccess.open("user://")
func delete_save():
	if dir.file_exists("savegame.json"):
		dir.remove("savegame.json")
		reset_all_global_data()

func reset_all_global_data():
	scene_number_House = 0
	scene_number_Bathroom = 0
	scene_name = ""
	#print("reseted!")
