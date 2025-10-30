extends Node2D

func _ready():
	# Start playing the cinematic
	$AnimationPlayer.play("cinematic1")

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC by default
		_skip_cinematic()

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "cinematic1":
		_skip_cinematic()

func _skip_cinematic():
	get_tree().change_scene_to_file("res://Scenes/game.tscn") # change to game scene
