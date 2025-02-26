extends Node


var music_menu_1 = load("res://Sfx/BGM/Menu.mp3")
var battle_music = load("res://Sfx/BGM/Battle Mix.mp3")
var menu_select = load("res://Sfx/Menu + Gameplay/Menu Select.mp3")
var mike_selected = load("res://Sfx/Menu + Gameplay/Character Select Gremlin.mp3")
var bc_selected = load("res://Sfx/Menu + Gameplay/Character Select Bing Chilling.mp3")
var sf_selected = load("res://Sfx/Menu + Gameplay/Character Select Smiley Face.mp3")

var dialogue_mike = load("res://Sfx/Menu + Gameplay/Gremlin Dialog.mp3")
var dialogue_bc = load("res://Sfx/Menu + Gameplay/Bing Chilling Dialog.mp3")
var dialogue_sf = load("res://Sfx/Menu + Gameplay/Smiley Dialog.mp3")

var bc_Attack = load("res://Sfx/Bing Chilling Moves/Vanilla Ice Cream.mp3")
var bc_Defend = load("res://Sfx/Bing Chilling Moves/Cookie Shield.mp3")
var bc_SkillA = load("res://Sfx/Bing Chilling Moves/Healing Lemonade.mp3")
var bc_SkillB = load("res://Sfx/Bing Chilling Moves/Lucky Sundae.mp3")
var bc_Ultimate = load("res://Sfx/Bing Chilling Moves/Ultimate Bing Chilling.mp3")

var mike_Attack = load("res://Sfx/Gremlin Moves/Bite.mp3")
var mike_Defend = load("res://Sfx/Gremlin Moves/Jokes.mp3")
var mike_SkillA = load("res://Sfx/Gremlin Moves/Triggered.mp3")
var mike_SkillB = load("res://Sfx/Gremlin Moves/Furry.mp3")
var mike_Ultimate = load("res://Sfx/Gremlin Moves/Second Eye.mp3")

var sf_Attack = load("res://Sfx/Smiley Face Moves/Axe Hit.mp3")
var sf_Defend = load("res://Sfx/Smiley Face Moves/Shield Block.mp3")
var sf_SkillA = load("res://Sfx/Smiley Face Moves/I Got Lucky.mp3")
var sf_SkillB = load("res://Sfx/Smiley Face Moves/Clutch.mp3")
var sf_Ultimate = load("res://Sfx/Smiley Face Moves/Face Reveal.mp3")


var nyala = false

#func play_sfx(Actor,Noise)

func PlaySFX(SFx):
	print_debug("PLAYED SOUND LOL ",SFx)
	if SFx == "bc_Idle" or SFx == "mike_Idle" or SFx == "sf_Idle":
		pass
	elif SFx == "bc_Attack":
		$SFX.stream = bc_Attack
	elif SFx == "bc_Defend":
		$SFX.stream = bc_Defend
	elif SFx == "bc_SkillA":
		$SFX.stream = bc_SkillA
	elif SFx == "bc_SkillB":
		$SFX.stream = bc_SkillB
	elif SFx == "bc_Ultimate":
		$SFX.stream = bc_Ultimate
	elif SFx == "mike_Attack":
		$SFX.stream = mike_Attack
	elif SFx == "mike_Defend":
		$SFX.stream = mike_Defend
	elif SFx == "mike_SkillA":
		$SFX.stream = mike_SkillA
	elif SFx == "mike_SkillB":
		$SFX.stream = mike_SkillB
	elif SFx == "mike_Ultimate":
		$SFX.stream = mike_Ultimate
	elif SFx == "sf_Attack":
		$SFX.stream = sf_Attack
	elif SFx == "sf_Defend":
		$SFX.stream = bc_Defend
	elif SFx == "sf_SkillA":
		$SFX.stream = sf_SkillA
	elif SFx == "sf_SkillB":
		$SFX.stream = sf_SkillB
	elif SFx == "sf_Ultimate":
		$SFX.stream = sf_Ultimate
	if SFx == "bc_Idle" or SFx == "mike_Idle" or SFx == "sf_Idle":
		pass
	else:
		$SFX.stream.loop = false
		$SFX.play()

func play_battle_menu():
	$music_menu.stream = battle_music
	$music_menu.play()
	
func stop_battle_menu():
	$music_menu.stream = battle_music
	$music_menu.stop()

func play_music_menu():
	$music_menu.stream = music_menu_1
	$music_menu.play()

func stop_music_menu():
	$music_menu.stream = music_menu_1
	$music_menu.stop()

func menu_select():
	$menu_select.stream = menu_select
	$menu_select.stream.loop = false
	$menu_select.play()

func mike_selected():
	$char_selected.stream = mike_selected
	$char_selected.stream.loop = false
	$char_selected.play()

func bc_selected():
	$char_selected.stream = bc_selected
	$char_selected.stream.loop = false
	$char_selected.play()

func sf_selected():
	$char_selected.stream = sf_selected
	$char_selected.stream.loop = false
	$char_selected.play()

func dialogue_sf():
	$dialogue.stream = dialogue_sf
	$dialogue.stream.loop = false	
	$dialogue.play()	

func dialogue_bc():
	$dialogue.stream = dialogue_bc	
	$dialogue.stream.loop = false	
	$dialogue.play()	

func dialogue_mike():
	$dialogue.stream = dialogue_mike
	$dialogue.stream.loop = false	
	$dialogue.play()


