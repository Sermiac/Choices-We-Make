extends Node
# Music
var music = true

# Per level stats
var lust: int = 0
var awareness: int = 0
var breed: int = 0

# Per save game stats
var day: int = 0
var money: int = 0
var lust_level: int = 1
var breed_level: int = 0


# Money costs
var upgrade_costs = {
	"lust": [0, 200, 300, 600],
	"breed": [100, 200, 300, 600]
}

var dir = DirAccess.open("user://")

# Gameplay related
var lust_reduce_multiplier = 0.0
var breed_reduce_multiplier = 0.00
# To interpret the level
var lust_upgrade = 0
var breed_upgrade = 0

const LUST_LEVELS := [
	{ "upgrade": 2.0,  "reduce": 6.0 },  # Level 1
	{ "upgrade": 4.0,  "reduce": 4.0 },  # Level 2
	{ "upgrade": 6.0,  "reduce": 3.0 },  # Level 3
	{ "upgrade": 8.0, "reduce": 2.0 }   # Level 4
]

const BREED_LEVELS := [
	{ "upgrade": 2.5,  "reduce": 5.0 },
	{ "upgrade": 4.0,  "reduce": 4.0 },
	{ "upgrade": 6.0,  "reduce": 3.0 },
	{ "upgrade": 8.0,  "reduce": 2.0 }
]

func upgrade():
	if lust_level > 0 and lust_level <= LUST_LEVELS.size():
		var data = LUST_LEVELS[lust_level - 1]
		lust_upgrade = data["upgrade"]
		lust_reduce_multiplier = data["reduce"]

	if breed_level > 0 and breed_level <= BREED_LEVELS.size():
		var data = BREED_LEVELS[breed_level - 1]
		breed_upgrade = data["upgrade"]
		breed_reduce_multiplier = data["reduce"]


func delete_save():
	if dir.file_exists("savegame.json"):
		dir.remove("savegame.json")
		reset_all_global_data()

func reset_data():
	lust = 0
	awareness = 0
	breed = 0

func reset_all_global_data():
	lust = 0
	awareness = 0
	breed = 0
	day = 0
	money = 0
	lust_level = 1
	breed_level = 0
	Globals.upgrade()

func save_on_file():
	# dictionary of data
	var save_data = {
	"lust": Globals.lust,
	"awareness": Globals.awareness,
	"breed": Globals.breed,
	"day": Globals.day,
	"money": Globals.money,
	"lust_level": Globals.lust_level,
	"breed_level": Globals.breed_level
	}
	
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE) # Creates the save file
	save_file.store_string(JSON.stringify(save_data)) # Writes the data
	print(ProjectSettings.globalize_path("user://savegame.json")) # Debug to print save location
	save_file.close()
	
func load_from_file():
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data:
		Globals.lust = data["lust"]
		Globals.awareness = data["awareness"]
		Globals.breed = data["breed"]
		Globals.day = data["day"]
		Globals.money = data["money"]
		Globals.lust_level = data["lust_level"]
		Globals.breed_level = data["breed_level"]
	Globals.upgrade()

func convert_number_to_percent(min_limit, max_limit, value) -> float: # normalize
	#var a = 120.0
	#var b = 865.0
	#var value = 800.0
	var percent: int = ((value - min_limit) / (max_limit - min_limit)) * 100.0
	return percent
	
func convert_percentage_to_number(min_limit, max_limit, percent) -> float: # normalize
	#a = 120.0
	#b = 865.0
	#var percent = 91.27
	var value = min_limit + (percent / 100.0) * (max_limit - min_limit)
	return value
