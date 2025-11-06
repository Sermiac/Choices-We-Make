extends Node

# Nodes
@onready var dialogue_box = $player/Camera2D/CanvasLayer/DialogueBox
@onready var player = $player
@onready var first_timer = $first_text_timer

# Buttons
var left_pressed = false
var right_pressed = false
var interact = false

# Text
var current_text = 0
var wait = 1
var story_end
var story_begin

# Change scene conditions met
var change_scene_conditions = false


func _init() -> void:
	Globals.save_on_file(1)


# Exit Button
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func save_player_data(scene):
	var position = "hold_position_%s" % scene
	Globals.player_data[position] = player.position.x
	Globals.player_data["hold_flip"] = player.get_child(0).flip_h

func get_interactables_properties():
	var group = {}
	var scene_interactables = {}
	# Get interactable nodes
	for node in get_tree().get_nodes_in_group("interactables"):
		scene_interactables[node.name] = node
	Globals.interactables = scene_interactables

	# link the nodes to numbers
	if group == {}:
		var index = 0
		for nodes in Globals.interactables:
			group[index] = nodes
			index += 1

	# initialize them 2 times (based on the amount of properties)
	for property in 3:
		for index in group:
			Globals.initialize_scene_nodes(group[index], property)


func _ready() -> void:
	Globals.story_mode = true
	change_scene_conditions = false
	# Get name of scene and starts counting
	Globals.scene_name = get_parent().name
	if Globals.scene_name == "House":
		Globals.scene_number_House += 1
		get_interactables_properties()
	elif Globals.scene_name == "Bathroom":
		Globals.scene_number_Bathroom += 1
		get_interactables_properties()
	# Player stats
	Globals.player = get_tree().get_nodes_in_group("player")
	Globals.get_player_data("position")
	Globals.get_player_data("flip")
	$player/AnimatedSprite2D.play("idle_animation")
	# First Scene Animation
	$AnimationPlayer.play("fade_out")
	# Story
	Globals.load_story_file()
	story_end = Globals.story_number_manager()
	Globals.save_on_file(2)
	



func _process(delta: float) -> void:
	if Globals.story_mode != true:
		$door/CollisionShape2D.disabled = false
		current_text = 0
		var walking_state = walking_animation()
		if walking_state == "left" or left_pressed == true:
			if wall_collided() != "right":
				player.position.x -= 200 * delta
		elif walking_state == "right" or right_pressed == true:
			if wall_collided() != "left":
				player.position.x += 200 * delta
		interactable_objects()


	elif Globals.story_mode == true:
		$door/CollisionShape2D.disabled = true
		if story_begin != null:
			if story_begin > current_text:
				current_text = story_begin
		if story_end != null and story_begin != null:
			if story_end > story_begin:
				$player/AnimatedSprite2D.play("idle_animation")
		text_manager(story_begin, story_end)
		if Input.is_action_just_pressed("ui_cancel"):
			if $first_text_timer.time_left > 0:
				$first_text_timer.timeout.emit()
				$first_text_timer.stop()
			else:
				$player/Camera2D/CanvasLayer/DialogueBox/text_timer.timeout.emit()
				$player/Camera2D/CanvasLayer/DialogueBox/text_timer.stop()


	if Input.is_action_pressed("fast") or Globals.button_E_pressed == true:
		wait -= delta * 1
		if Globals.story_mode == true and wait < 0.5:
			$first_text_timer.start(0.02)
			wait = 1

# Returns the name of the wall the player collided with
func wall_collided() -> String:
	var wall_name = wall.name.replace("wall_", "") if wall else ""
	return wall_name

# Signals when character enters a specific area //------//-------//------//
var area_entered = false
var area_name
var wall
func _on_player_area_entered(area: Area2D) -> void:
	if area.name.contains("wall"):
		wall = area
		return
	area_name = area
	area_entered = true

# Signals when character exits a specific area //------//-------//------//
func _on_player_area_exited(area: Area2D) -> void:
	if area.name.contains("wall"):
		wall = ""
		return
	if area.get_child_count() > 1 and area.get_child(1).name == "Label_interact":
		var label = area.get_child(1)
		label.visible = false
	area_entered = false

# Controls walking animation
func walking_animation() -> StringName:
	var character_animation = $player/AnimatedSprite2D
	if Input.is_action_pressed("left") or left_pressed == true:
		character_animation.flip_h = true
		character_animation.play("walking_animation")
		return "left"
	elif Input.is_action_pressed("right") or right_pressed == true:
		character_animation.flip_h = false
		character_animation.play("walking_animation")
		return "right"
	else:
		character_animation.play("idle_animation")
		return ""

# Controls inputs from touchpad
func _on_area_2d_right_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			right_pressed = true
		else:
			right_pressed = false

func _on_area_2d_left_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			left_pressed = true
		else:
			left_pressed = false
			


# Touchpad Movement
func _on_area_2d_right_mouse_exited() -> void:
	right_pressed = false

func _on_area_2d_left_mouse_exited() -> void:
	left_pressed = false

# Touchpad Interact
func _on_interact_button_down() -> void:
	Globals.button_E_pressed = true
	
func _on_interact_button_up():
	Globals.button_E_pressed = false

# Interaction logic control
func interact_logic_area_entered() -> bool:
	if Input.is_action_pressed("interact") and area_entered and interact != true:
		return true
	elif Globals.button_E_pressed == true and area_entered == true and interact != true:
		return true
	else: return false


# Text logic
var timer = false
func find_and_execute_text(chapter_number = null, text_number = null):
	if !chapter_number and !text_number:
		dialogue_box.show_text("")
		$player/Camera2D/CanvasLayer/DialogueBox/Panel/RichTextLabel2.text = ""
		$player/Camera2D/CanvasLayer/DialogueBox.visible = false
		$player/Camera2D/CanvasLayer/DialogueBox/text_timer.stop()
		$player/Camera2D/CanvasLayer/DialogueBox/text_timer.timeout.emit()
		return
	var text = Globals.story_manager(chapter_number,text_number)
	if timer == false:
		dialogue_box.show_text(text)
		$player/Camera2D/CanvasLayer/DialogueBox/Panel/RichTextLabel2.text = ""
		timer = true
	elif Globals.story_mode == false:
		dialogue_box.show_text(text)
		$player/Camera2D/CanvasLayer/DialogueBox/Panel/RichTextLabel2.text = ""

# Timers logic
func _on_text_timer_timeout() -> void:
	timer = false
	if Globals.story_mode == true:
		current_text += 1

var first_text = false
func _on_first_text_timer_timeout() -> void:
	if current_text == 0:
		first_text = true

# Automatic story manager
func text_manager(specific_text = null, specific_last_number = null):
	var last_number = specific_last_number
	var input = Input.is_action_pressed("interact") or Globals.button_E_pressed == true or Input.is_action_just_pressed("ui_cancel")
	if first_text == true:
		current_text += 1
		find_and_execute_text("chapter_1", str(current_text))
		first_text = false
		return
	elif Globals.story_mode == true and current_text > 0:
		if input and area_entered:
			area_name.get_child(0).disabled = true
			area_name.get_child(2).play(str(area_name.name) + "_idle")
			find_and_execute_text("chapter_1", str(current_text))
		elif input or area_entered:
			if current_text <= last_number:
				find_and_execute_text("chapter_1", str(current_text))
				if animation_transition == true:
					area_name.get_child(0).disabled = true
					area_name.get_child(2).play(str(area_name.name) + "_idle")
			if current_text > last_number:
				Globals.story_mode = false
				find_and_execute_text()
				if animation_transition == true:
					transition("house")
			
	elif Globals.story_mode == false:
		$player/Camera2D/CanvasLayer/DialogueBox/text_timer.timeout.emit()
		find_and_execute_text("chapter_1", str(specific_text))
		

func choose_story_lines(begin, end):
	find_and_execute_text()
	story_begin = begin
	story_end = end
	Globals.story_mode = true

var animation_transition
func transition(scene = null):
	if wait_anim == "fade_in":
		if scene:
			get_tree().change_scene_to_file("res://Scenes/%s.tscn" % scene)
			animation_transition = false
			
	if wait_anim == "fade_out":
		animation_transition = false

var wait_anim
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	wait_anim = anim_name
	if anim_name == "fade_out":
		return
	if anim_name == "fade_in":
		if change_scene_conditions and area_name == $door:
			if Globals.scene_name == "House":
				get_tree().change_scene_to_file("res://Scenes/bathroom.tscn")
				interact = true
				Globals.story_mode = true
			if Globals.scene_name == "Bathroom":
				get_tree().change_scene_to_file("res://Scenes/house.tscn")
				interact = true
				Globals.story_mode = true
		if has_node("bed") and area_name == $bed:
			choose_story_lines(Globals.story_number_manager(1) + 1, Globals.story_number_manager(2))
			animation_transition = true



func interactable_objects():
	if area_entered == true:
		if area_name.get_child_count() > 1 and area_name.get_child(1).name == "Label_interact":
			var label = area_name.get_child(1)
			label.visible = true
		
			
	if interact_logic_area_entered() == true:
		if area_name == $door:
			if !change_scene_conditions:
				if has_node("cellphone") and $cellphone.visible == false and $cellphone/CollisionShape2D.disabled == true:
					change_scene_conditions = true
				elif has_node("bed") and $bed.visible == true and $cellphone/CollisionShape2D.disabled == true:
					text_manager(100)
				else:
					text_manager(99)
			if change_scene_conditions:
				save_player_data(Globals.scene_name)
				$AnimationPlayer.play("fade_in")

		if Globals.scene_name == "House":
			if area_name == $cellphone:
				choose_story_lines(Globals.story_number_manager() + 1, Globals.story_number_manager(1))
				if $bed.visible == false:
					change_scene_conditions = true
			elif area_name == $bed:
				if $cellphone/CollisionShape2D.disabled == true:
					save_player_data(Globals.scene_name)
					$AnimationPlayer.play("fade_in")
					change_scene_conditions = true
				else:
					text_manager(99)
		elif Globals.scene_name == "Bathroom":
			if area_name == $gloryhole:
				choose_story_lines(Globals.story_number_manager() + 1, Globals.story_number_manager(1))
				change_scene_conditions = true
