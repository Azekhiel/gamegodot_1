extends Control


onready var text = get_parent().get_node("dialogue_win_bc").win_bc


var dialogue_index = 0
var finished
var active

var position
var expression
var alignment

func _ready():
	load_dialogue()
	MusicMenu.dialogue_bc()

func _physics_process(delta):
	if active:
		if Input.is_action_just_pressed("ui_accept"):
			if finished == true:
				load_dialogue()
			else:
				$MikePlayer/Tween.stop_all()
				$MikePlayer/RichTextLabel.percent_visible = 1


				finished = true
				
	if $MikePlayer/TextBox2/Label.text == "Mike":
		if alignment == "Good":
			$MikePlayer.visible = true
			$MikeEnemy.visible = false
			$BcPlayer.visible = false
			$BcEnemy.visible = false
		elif alignment == "Bad":
			$MikePlayer.visible = false
			$MikeEnemy.visible = true
			$BcPlayer.visible = false
			$BcEnemy.visible = false
	if $MikePlayer/TextBox2/Label.text == "Bing Chilling":
		$MikePlayer.visible = false
		$MikeEnemy.visible = false
		if alignment == "Good":
			$BcPlayer.visible = true
			$BcEnemy.visible = false
		if alignment == "Bad":
			$BcPlayer.visible = false
			$BcEnemy.visible = true

	

	
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
		
		$MikePlayer.visible = false
		$MikePlayer/RichTextLabel.text = text[dialogue_index]["Text"]
		$MikePlayer/TextBox2/Label.text = text[dialogue_index]["Name"]
		$Button1.text = text[dialogue_index]["Choices"][0]
		$Button2.text = text[dialogue_index]["Choices"][1]
		$Button3.text = text[dialogue_index]["Choices"][2]

		$MikeEnemy/RichTextLabel.text = text[dialogue_index]["Text"]
		$MikeEnemy/TextBox2/Label.text = text[dialogue_index]["Name"]
		
		$BcPlayer/RichTextLabel.text = text[dialogue_index]["Text"]
		$BcPlayer/Label.text = text[dialogue_index]["Name"]
		
		$BcEnemy/RichTextLabel.text = text[dialogue_index]["Text"]
		$BcEnemy/Label.text = text[dialogue_index]["Name"]

		position = text[dialogue_index]["Position"]
		expression = text[dialogue_index]["Expression"]
		alignment = text[dialogue_index]["Alignment"]
		
		$MikePlayer/RichTextLabel.percent_visible = 0
		$MikePlayer/Tween.interpolate_property(
			$MikePlayer/RichTextLabel, "percent_visible", 0 , 1, 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$MikePlayer/Tween.start()
		
		$MikeEnemy/Tween.start()
		$MikeEnemy/RichTextLabel.percent_visible = 0
		$MikeEnemy/Tween.interpolate_property(
			$MikeEnemy/RichTextLabel, "percent_visible", 0 , 1, 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		
		$BcPlayer/Tween.start()
		$BcPlayer/RichTextLabel.percent_visible = 0
		$BcPlayer/Tween.interpolate_property(
			$BcPlayer/RichTextLabel, "percent_visible", 0 , 1, 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$BcPlayer/Tween.start()

		$BcEnemy/Tween.start()
		$BcEnemy/RichTextLabel.percent_visible = 0
		$BcEnemy/Tween.interpolate_property(
			$BcEnemy/RichTextLabel, "percent_visible", 0 , 1, 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$BcEnemy/Tween.start()

	else:
		$MikePlayer.visible = false
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
	get_tree().change_scene("res://before_mike_jalur_sf.tscn")


func _on_Button3_pressed():
	if $Button3.text == "3":
		$Button1.text == ""
		$Button2.text == ""
		$Button3.text == ""
		text = get_parent().get_node("Dialogue").after_choice_3
		dialogue_index = 0
		load_dialogue()
