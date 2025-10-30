extends Control

@onready var label = $Panel/RichTextLabel
@onready var continue_text = $Panel/RichTextLabel2
@onready var timer = $Timer
@onready var text_timer = $text_timer

var full_text = ""
var char_index = 0
var typing_speed = 0.02

func _process(_delta: float) -> void:
	if Input.is_action_pressed("fast") or Globals.button_E_pressed == true:
		typing_speed = 0.002
	else:
		typing_speed = 0.04
		
	if timer.is_stopped() == false:
		timer.wait_time = typing_speed

func show_text(text: String):
	self.visible = true
	full_text = text
	char_index = 15
	label.text = full_text.substr(0, char_index)
	timer.start(typing_speed)


func _on_timer_timeout():
	if char_index < full_text.length():
		label.text += full_text[char_index]
		char_index += 1
	else:
		timer.stop()
		if Input.is_action_pressed("fast") or Globals.button_E_pressed == true:
			text_timer.start(0.3)  # only short delay
		elif Globals.story_mode == false:
			text_timer.start(3.0)
		else:
			text_timer.start(1.0)

func _on_text_timer_timeout() -> void:
	if Globals.story_mode == true:
		continue_text.text = "[b]Press E to continue..."
	else:
		continue_text.text = ""
		label.text = ""
		self.visible = false
