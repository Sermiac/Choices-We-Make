extends Node2D

var max_lust := 100
var min_lust := 0
var max_breed := 100
var min_breed := 0
var max_awareness := 100
var min_awareness := 0
var hold_dir_lust := 0
var hold_dir_breed := 0 # 1 = increase, -1 = decrease, 0 = none

var time_accumulator_lust := 0.0
var time_accumulator_awareness := 0.0
var time_accumulator_breed := 0.0

var step_time_lust := 0.15 # seconds per step
var step_time_breed := 0.15 # seconds per step
var step_time_awareness = 0.15 # seconds per step
var multiplier = 0

var step_time_limit = 0.15
var new_step_time_awareness = step_time_limit

# Bar
@onready var awareness_bar = $awareness_bar
var max_limit_bar = 0.15
var min_limit_bar = 0.095
var displayed_value = 0.0

# Timer
var timer = 4
var timer_signal = 0
var scene_data = ""

func _ready():
	$AnimationPlayer2.play("RESET_2")
	_update_label_girl_stats()
	Globals.upgrade()
	update()
	_migrate_animations()
	for button in [$LustButton, $BreedButton, $StartButton]:
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button.name))
		button.mouse_exited.connect(_on_button_mouse_exited)


func update():
	step_time_awareness = 0.5
	step_time_lust = 0.5
	step_time_breed = 0.5

func _process(delta):
	if not Globals.awareness == 100 and start != 1: # Stop interactions. Lose game
		main_gameplay(delta)
	var percent = convert_number_to_percent(min_limit_bar, max_limit_bar, step_time_awareness)
	$AnimationPlayer2.speed_scale = (100 - percent) / 30
	if percent <= 99:
		$AnimationPlayer2.play("1bar_animation")
	elif percent >= 100:
		if $AnimationPlayer2.current_animation_position <= 0.1:
			$AnimationPlayer2.play("RESET_2")
	
	if timer <= 4:
		timer = timer + delta * 1
		print("timer: ", timer)
	
	if timer_signal == 1 and timer >= 4:
		change_scene(scene_data, 4)
	
# --- Lust Button ---
func _on_lust_button_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			hold_dir_lust = 1
			print("level: ", Globals.lust_level,
			"\n", "upgrade: ", Globals.lust_upgrade, 
			"\n", "step time awareness: ", step_time_awareness
			)
		else:
			if hold_dir_lust == 1:
				multiplier = 0
				step_time_lust = 0.15
				step_time_awareness = new_step_time_awareness
				hold_dir_lust = 0

# --- Breed Button ---
func _on_breed_button_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			hold_dir_breed = 1
			print(Globals.breed_level, hold_dir_breed)
		else:
			if hold_dir_breed == 1:
				multiplier = 0
				step_time_breed = 0.15
				step_time_awareness = new_step_time_awareness
				hold_dir_breed = 0

#resets button
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if hold_dir_breed == 1:
			multiplier = 0
			step_time_breed = 0.15
			step_time_awareness = new_step_time_awareness
			hold_dir_breed = 0
			
		if hold_dir_lust == 1:
			multiplier = 0
			step_time_lust = 0.15
			step_time_awareness = new_step_time_awareness
			hold_dir_lust = 0

# Define all animations and their conditions
const ANIMATIONS := [
	{ "lust_min": 25, "lust_max": 49, "breed_min": 0,  "breed_max": 24, "name": "1lust_1" },
	{ "lust_min": 25, "lust_max": 49, "breed_min": 25, "breed_max": 49, "name": "2lust_1_breed_1" },
	{ "lust_min": 50, "lust_max": 74, "breed_min": 0,  "breed_max": 24, "name": "3lust_2" },
	{ "lust_min": 50, "lust_max": 74, "breed_min": 25, "breed_max": 49, "name": "4lust_2_breed_1" },
	{ "lust_min": 75, "lust_max": 98, "breed_min": 50, "breed_max": 74, "name": "5lust_3_breed_2" },
	{ "lust_min": 75, "lust_max": 98, "breed_min": 50, "breed_max": 74, "name": "6lust_4_breed_2" },
	{ "lust_min": 98, "lust_max": 100, "breed_min": 75, "breed_max": 98, "name": "7lust_4_breed_3" },
	{ "lust_min": 98, "lust_max": 100, "breed_min": 98, "breed_max": 100, "name": "8lust_4_breed_4" }
]

var start = 0
func _on_start_button_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Globals.awareness >= 100:
			return

		var lust := Globals.lust
		var breed := Globals.breed
		var animation_name := get_animation_for_stats(lust, breed)

		if animation_name != "":
			start = 1
			print(animation_name)
			$AnimationPlayer.play(animation_name)
			$AnimationPlayer3.play("StartButton_pressed")
			#Audio for start button
			$AudioStreamPlayer2.stream = load("res://Assets/Sounds/StartPressed.wav")
			$AudioStreamPlayer2.play()
		else:
			print("⚠️ No matching animation for lust=%s, breed=%s" % [lust, breed])
			

func get_animation_for_stats(lust: float, breed: float) -> String:
	var sorted_anims = ANIMATIONS.duplicate()
	sorted_anims.sort_custom(func(a, b):
		return (b.lust_min + b.breed_min) - (a.lust_min + a.breed_min)
	)
	for anim_data in sorted_anims:
		if lust >= anim_data.lust_min and breed >= anim_data.breed_min:
			return anim_data.name
	return ""


func _update_label_girl_stats():
	$Label_lust.text = str(Globals.lust)
	$Label_awareness.text = str(Globals.awareness)
	$Label_breed.text = str(Globals.breed)
	$Label_day.text = str(Globals.day)

var wait_lose = 0
func wait_awareness_animation(lose_signal): # Activiates when game over animation finishes
	if lose_signal == "0awareness_100":
		if wait_lose == 0:
			GeneralMusic.playing = true
		else:
			pass
		get_tree().change_scene_to_file("res://Scenes/menu.tscn") # Returns to main menu
		Globals.reset_data()
		Globals.save_on_file()


func wait_lust_breed_animation(anim_signal): # Activiates when animation finishes
	var rewards = {
	"1lust_1": 50,
	"2lust_1_breed_1": 75,
	"3lust_2": 100,
	"4lust_2_breed_1": 125,
	"5lust_3_breed_2": 150,
	"6lust_4_breed_2": 175,
	"7lust_4_breed_3": 200,
	"8lust_4_breed_4": 300
	}
	if rewards.has(anim_signal):
		Globals.money += rewards[anim_signal]
		Globals.day += 1
		$Label_money.text = str("+",rewards[anim_signal])
		$AnimationPlayer3.play("1money")
		change_scene("res://Scenes/upgrade.tscn", 2)
		
# /// --- Function for buttons --- ///
func main_gameplay(delta):
	awareness_bar.min_value = min_limit_bar
	awareness_bar.max_value = max_limit_bar
	displayed_value = lerp(displayed_value, step_time_awareness, 2 * delta)
	awareness_bar.value = displayed_value
	if step_time_awareness < step_time_limit and hold_dir_lust == 0 and hold_dir_breed == 0:
		step_time_awareness = min(
			step_time_awareness + min(0.095 / Globals.lust_reduce_multiplier, 0.095 / Globals.breed_reduce_multiplier) * delta,
			step_time_limit
		)
		new_step_time_awareness = step_time_awareness
		print("Recovering:", step_time_awareness)

	# === L Button Pressed ===
	if hold_dir_lust != 0:
		time_accumulator_lust += delta
		time_accumulator_awareness += delta
		if time_accumulator_lust >= step_time_lust:
			step_time_lust = lerp(step_time_lust, 0.095 / Globals.lust_upgrade, delta * Globals.lust_upgrade)
			step_time_lust = clampf(step_time_lust, 0.095 / (Globals.lust_upgrade / 2.0), 0.15)
			Globals.lust += hold_dir_lust # Adds the calculation to the stats
			Globals.lust = clamp(Globals.lust, min_lust, max_lust) # Limits counter
			#print("step time: ---///---", step_time_lust)
			time_accumulator_lust = 0.0
			_update_label_girl_stats()

		if time_accumulator_awareness >= step_time_awareness: # Awareness for lust
			min_limit_bar = 0.095 / (Globals.lust_reduce_multiplier / 2.0)
			step_time_awareness = lerp(step_time_awareness, 0.095 / (Globals.lust_reduce_multiplier / 2.0), delta * Globals.lust_reduce_multiplier)
			step_time_awareness = clampf(step_time_awareness, 0.095 / (Globals.lust_reduce_multiplier / 2.0), 0.15)
			Globals.awareness += hold_dir_lust
			Globals.awareness = clamp(Globals.awareness, min_awareness, max_awareness)
			new_step_time_awareness = step_time_awareness
			print("step time on lust button: ---///---", step_time_awareness)
			time_accumulator_awareness = 0.0
			_update_label_girl_stats()
				
	# === B Button Pressed ===
	if hold_dir_breed != 0 and Globals.breed_level >= 1:
		time_accumulator_breed += delta
		time_accumulator_awareness += delta
		if time_accumulator_breed >= step_time_breed:
			step_time_breed = lerp(step_time_breed, 0.095 / Globals.breed_upgrade, delta * Globals.breed_upgrade)
			step_time_breed = clampf(step_time_breed, 0.095 / (Globals.breed_upgrade / 2.0), 0.15)
			Globals.breed += hold_dir_breed
			Globals.breed = clamp(Globals.breed, min_breed, max_breed)
			print("breed: ---///---", step_time_awareness)
			time_accumulator_breed = 0.0
			_update_label_girl_stats()

		if time_accumulator_awareness >= step_time_awareness: # Awareness for lust
			min_limit_bar = 0.095 / (Globals.breed_reduce_multiplier / 2.0)
			step_time_awareness = lerp(step_time_awareness, 0.095 / (Globals.breed_reduce_multiplier / 2.0), delta * Globals.breed_reduce_multiplier)
			step_time_awareness = clampf(step_time_awareness, 0.095 / (Globals.breed_reduce_multiplier / 2.0), 0.15)
			min_limit_bar = 0.095 / (Globals.lust_reduce_multiplier / 2.0)
			Globals.awareness += hold_dir_breed
			Globals.awareness = clamp(Globals.awareness, min_awareness, max_awareness)
			new_step_time_awareness = step_time_awareness
			print("step time on breed button: ---///---", step_time_awareness)
			time_accumulator_awareness = 0.0
			_update_label_girl_stats()
			
	if Globals.awareness == 100: # Method to detect when the player loses for high awareness
		print("Counter is enough! You lose")
		if GeneralMusic.playing == true:
			GeneralMusic.playing = false
		else:
			wait_lose = 1
		$AnimationPlayer.play("0awareness_100")
		
		
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
func _migrate_animations():
	# CREATES A LIBRARY OF ANIMATIONS FROM AnimatedSprite2D TO AnimationPlayer
	# AUTOMATIC PROCESS IF YOU WANT TO CONTINUE ADDING ANIMATIONS THROUGH AnimatedSprite2D
	var sprite_frames: SpriteFrames = sprite.sprite_frames
	var anim_names: PackedStringArray = sprite_frames.get_animation_names()
	var lib := AnimationLibrary.new()

	for anim_name in anim_names:
		var new_anim := Animation.new()
		var frames := sprite_frames.get_frame_count(anim_name)
		var fps := sprite_frames.get_animation_speed(anim_name)
		if fps <= 0:
			fps = 12.0  # fallback speed

		var duration := float(frames) / fps
		new_anim.length = duration
		new_anim.loop_mode = (
			Animation.LOOP_LINEAR if sprite_frames.get_animation_loop(anim_name)
			else Animation.LOOP_NONE
		)

		# Track 0: set animation name
		var track_anim := new_anim.add_track(Animation.TYPE_VALUE)
		new_anim.track_set_path(track_anim, "AnimatedSprite2D:animation")
		new_anim.track_insert_key(track_anim, 0.0, anim_name)

		# Track 1: animate frame progression
		var track_frame := new_anim.add_track(Animation.TYPE_VALUE)
		new_anim.track_set_path(track_frame, "AnimatedSprite2D:frame")
		for i in range(frames):
			new_anim.track_insert_key(track_frame, i / fps, i)
			
		# Track 2: integrate sounds
		var sound_track = new_anim.add_track(Animation.TYPE_METHOD)
		new_anim.track_set_path(sound_track, NodePath("."))
		new_anim.track_insert_key(sound_track, 0.0, {
		"method": "play_sound",
		"args": [anim_name]
		})
		new_anim.track_set_key_value(sound_track, 0, anim_name)

		# --- SOUND LENGTH HANDLING ---
		var sound_path = get_sound_path(anim_name)
		if ResourceLoader.exists(sound_path):
			var sound_res = load(sound_path)
			if sound_res is AudioStream:
				var sound_len = sound_res.get_length()
				if sound_len > 0.0:
					new_anim.length = max(new_anim.length, sound_len)
		# -----------------------------
		
		lib.add_animation(anim_name, new_anim)

	# Avoid duplicate libraries
	if anim_player.has_animation_library(""):
		anim_player.remove_animation_library("")
	anim_player.add_animation_library("", lib)
	
	print("✅ All animations migrated into AnimationPlayer")

func get_sound_path(anim_name: String) -> String:
	var prefix = ""
	for c in anim_name:
		if c.is_valid_int():
			prefix += c
		else:
			break
	return "res://Assets/Sounds/%sSound.mp3" % prefix

func play_sound(anim_name: String):
	var sound_path = get_sound_path(anim_name)
	if not ResourceLoader.exists(sound_path):
		push_warning("⚠️ Sound not found: " + sound_path)
		return
	var player = $AudioStreamPlayer
	print(sound_path)
	player.stream = load(sound_path)
	player.play()

func convert_number_to_percent(min_limit, max_limit, value) -> float: # normalize
	#var a = 120.0
	#var b = 865.0
	#var value = 800.0
	var percent: int = ((value - min_limit) / (max_limit - min_limit)) * 100.0
	return percent
	
func change_scene(scene, start_time):
	timer = start_time
	scene_data = scene
	timer_signal = 1
	if timer >= 4:
		get_tree().change_scene_to_file(scene)
	
func _on_button_mouse_entered(button_name: String) -> void:
	if start != 1:
		$AnimationPlayer3.play(button_name + "_hover")
	

func _on_button_mouse_exited() -> void:
	if start != 1:
		$AnimationPlayer3.play("RESET_3")
