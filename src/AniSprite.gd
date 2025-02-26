extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var CharaName

var targetmove = ["Attack","Defend","SkillA","SkillB","Ultimate"]

# Called when the node enters the scene tree for the first time.
func _ready():
	#print_debug("PENIS BALLS")
	pass # Replace with function body.

func PlaySFX(move):
	if CharaName == "BingChillin":
		MusicMenu.PlaySFX(("bc_"+move))
	if CharaName == "Gremlin":
		MusicMenu.PlaySFX(("mike_"+move))
	if CharaName == "SmileyFace":
		MusicMenu.PlaySFX(("sf_"+move))

func PlayAnimation(ani):
	if get_animation() != "Idle":
		play(ani)
	if ani != "Idle":
		PlaySFX(ani)
	
		
		
