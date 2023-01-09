extends Control


onready var text = get_parent().get_node("Dialogue").dialogue_1

var char1_1 = preload("res://Asset/Sprites/BingChillin/Bing Chilling.PNG")
var char1_2 

var dialogue_index = 0
var finished
var active

var position
var expression

func _ready():
	load_dialogue()

func _physics_process(delta):
	if active:
		if Input.is_action_just_pressed("ui_accept"):
			if finished == true:
				load_dialogue()
			else:
				$TextBox/Tween.stop_all()
				$TextBox/RichTextLabel.percent_visible = 1
				finished = true
	
	if $TextBox/TextBox2/Label.text == "Char_1":
		$Char1.visible = true
		$Char2.visible = false
		if position == "1":
			$Char1.global_position = get_parent().get_node("1").position
		if position == "2":
			$Char1.global_position = get_parent().get_node("2").position
		if position == "3":
			$Char1.global_position = get_parent().get_node("3").position
		if position == "4":
			$Char1.global_position = get_parent().get_node("4").position
		if expression == "":
			$Char1.texture = char1_1

	if $TextBox/TextBox2/Label.text == "Char_2":
		$Char2.visible = true
		$Char1.visible = false
		if position == "1":
			$Char2.global_position = get_parent().get_node("1").position
		if position == "2":
			$Char2.global_position = get_parent().get_node("2").position
		if position == "3":
			$Char2.global_position = get_parent().get_node("3").position
		if position == "4":
			$Char2.global_position = get_parent().get_node("4").position

	
	if $Button1.text == "":
		$Button1.visible = false
	else:
		$Button1.visible = true

	if $Button2.text == "":
		$Button2.visible = false
	else:
		$Button2.visible = true

	if $Button3.text == "":
		$Button3.visible = false
	else:
		$Button3.visible = true

func load_dialogue():
	if dialogue_index < text.size():
		active = true
		finished = false
		
		$TextBox.visible = true
		$TextBox/RichTextLabel.text = text[dialogue_index]["Text"]
		$TextBox/TextBox2/Label.text = text[dialogue_index]["Name"]
		$Button1.text = text[dialogue_index]["Choices"][0]
		$Button2.text = text[dialogue_index]["Choices"][1]
		$Button3.text = text[dialogue_index]["Choices"][2]
		
		position = text[dialogue_index]["Position"]
		expression = text[dialogue_index]["Expression"]
		
		$TextBox/RichTextLabel.percent_visible = 0
		$TextBox/Tween.interpolate_property(
			$TextBox/RichTextLabel, "percent_visible", 0 , 1, 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$TextBox/Tween.start()
	else:
		$TextBox.visible = false
		finished = true
		active = false
	dialogue_index += 1

func _on_Tween_tween_completed(object, key):
	finished = true


func _on_Button1_pressed():
	if $Button1.text == "1":
		$Button1.text == ""
		$Button2.text == ""
		$Button3.text == ""
		text = get_parent().get_node("Dialogue").after_choice_1
		dialogue_index = 0
		load_dialogue()

func _on_Button2_pressed():
	if $Button2.text == "2":
		$Button1.text == ""
		$Button2.text == ""
		$Button3.text == ""
		text = get_parent().get_node("Dialogue").after_choice_2
		dialogue_index = 0
		load_dialogue()


func _on_Button3_pressed():
	if $Button3.text == "3":
		$Button1.text == ""
		$Button2.text == ""
		$Button3.text == ""
		text = get_parent().get_node("Dialogue").after_choice_3
		dialogue_index = 0
		load_dialogue()
