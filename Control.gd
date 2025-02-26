extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_bc_selected_pressed():
	MusicMenu.menu_select()
	get_tree().change_scene("res://before_mike.tscn")
	MusicMenu.stop_music_menu()



func _on_mike_selected_pressed():
	MusicMenu.menu_select()
	get_tree().change_scene("res://before_bc.tscn")
	MusicMenu.stop_music_menu()


func _on_sf_selected_pressed():
	MusicMenu.menu_select()
	get_tree().change_scene("res://before_bc_jalur_sf.tscn")
	MusicMenu.stop_music_menu()


func _on_bc_pressed():
	MusicMenu.menu_select()
	$mike_selected/mike.visible = true
	$MikeSelected/Mike.visible = true
	$sf_selected/sf.visible = true
	$SmileyFaceSelected/SmileyFace.visible = true

	$bc_selected/bc.visible = false
	$BingChillingSelected/BingChilling.visible = false
	MusicMenu.bc_selected()


func _on_mike_pressed():
	MusicMenu.menu_select()
	$bc_selected/bc.visible = true
	$BingChillingSelected/BingChilling.visible = true
	$sf_selected/sf.visible = true
	$SmileyFaceSelected/SmileyFace.visible = true
	
	$mike_selected/mike.visible = false
	$MikeSelected/Mike.visible = false
	MusicMenu.mike_selected()



func _on_sf_pressed():
	MusicMenu.menu_select()
	$bc_selected/bc.visible = true
	$BingChillingSelected/BingChilling.visible = true
	$mike_selected/mike.visible = true
	$MikeSelected/Mike.visible = true

	
	
	$sf_selected/sf.visible = false
	$SmileyFaceSelected/SmileyFace.visible = false
	MusicMenu.sf_selected()
