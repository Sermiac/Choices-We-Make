extends Control

func _ready():
	if FileAccess.file_exists("user://savegame.json"):
		$MarginContainer/VBoxContainer/Continue.set_disabled(false)
	else:
		$MarginContainer/VBoxContainer/Continue.set_disabled(true)

# el codigo de abajo son los botones
func _on_continue_pressed():
	if not FileAccess.file_exists("user://savegame.json"):
		return

	Globals.load_from_file()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_new_pressed():
	if not FileAccess.file_exists("user://savegame.json"):
		Globals.upgrade()
		get_tree().change_scene_to_file("res://Scenes/cinematic1.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/new_game_confirmation.tscn")
		

func _on_exit_pressed():
	get_tree().quit()

func _on_music_pressed():
	if Globals.music == true:
		Globals.music = false
		#GeneralMusic.autoplay = Globals.music
		GeneralMusic.playing = Globals.music
		print(GeneralMusic.autoplay, GeneralMusic.playing)

	elif Globals.music == false:
		Globals.music = true
		#GeneralMusic.autoplay = Globals.music
		GeneralMusic.playing = Globals.music
		print(GeneralMusic.autoplay, GeneralMusic.playing)

func _on_music_2_pressed() -> void:
	if GeneralMusic.count < 3:
		GeneralMusic.count += 1
		var music = "res://Assets/Music/Music_%s.mp3" %GeneralMusic.count
		GeneralMusic.stream = load(music)
		GeneralMusic.play()
		print(GeneralMusic.count)
		print(music)
	else:
		GeneralMusic.count = 1
		var music = "res://Assets/Music/Music_%s.mp3" %GeneralMusic.count
		GeneralMusic.stream = load(music)
		GeneralMusic.play()
		print(GeneralMusic.count)
		print(music)
