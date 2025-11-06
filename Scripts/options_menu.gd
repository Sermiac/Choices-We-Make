extends Node

@onready var master_button = $MarginContainer/BoxContainer/master_button

func _ready() -> void:
	pass




func _on_master_slider_value_changed(volume: float) -> void:
	print(volume)
	music.volume_db = volume


func _on_master_button_toggled(toggled_on: bool) -> void:
	if music.playing == true:
		music.playing = false
	elif music.playing == false:
		music.play()
