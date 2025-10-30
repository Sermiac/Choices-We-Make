extends Node2D

func _on_exit_pressed() -> void:
	if anim_playing != true:
		get_tree().change_scene_to_file("res://Scenes/menu.tscn") # Returns to main menu
		Globals.save_on_file()
		anim_playing = false

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Detects when ESC is pressed
		if anim_playing != true:
			get_tree().change_scene_to_file("res://Scenes/menu.tscn") # Returns to main menu
			Globals.save_on_file()
			anim_playing = false


var anim_playing = false
func _on_animation_player_animation_started(anim_name) -> void:
	var anims = {
	"0awareness_100": 0,
	"1lust_1": 50,
	"2lust_1_breed_1": 50,
	"3lust_2": 75,
	"4lust_2_breed_1": 100,
	"5lust_3_breed_2": 125,
	"6lust_4_breed_2": 150,
	"7lust_4_breed_3": 175,
	"8lust_4_breed_4": 200
	}
	if anims.has(anim_name):
		anim_playing = true
		$MarginContainer/VBoxContainer/Exit.disabled = true
