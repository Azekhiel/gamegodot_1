extends Control

#MUNEKI's Note:
#To edit what happens after someone dies, look up FightPhaseEnd
#This thing bellow changes who fights who, later on i'l add a way to implement stuff
var Character = "BingChillin"
var Enemy = "SmileyFace"

var CharacterDetailFile = ("res://CharaDetails/"+Character+"_CharaDetails.json")#Test_icle_CharaDetails.json"
var EnemyDetailFile = ("res://CharaDetails/"+Enemy+"_CharaDetails.json")

var TurnOrder
var TurnOrderDef = ["Player","Enemy"] #Default

var EffectHistory = 0

var TurnProgress
var TurnCount = 0

var Victory = false

var AttackDamage

var StatusCheck
#dont delette this
var CharaDetail
var EnemyDetail
var Detail

var RandBuffGiven #bug fuxing

var EnemyMove #what move the enemy will take
var CurrentEffectHistory

const EffectSquarePackage = preload("res://src/Effect.tscn")
#const AniSpritePackage = preload("res://src/AnimatedSprite.tscn")
var EffectInQuestion #holds the name of effect being handled

signal textbox_closed
signal phase_over

var AntiDeathBearer = []

var Movelist = ["Attack","Defend","SkillA","SkillB","Ultimate"]

onready var AttackButton = $ActionPanel/Attack
onready var DefendButton = $ActionPanel/Defend
onready var SkillAButton = $ActionPanel/SkillA
onready var SkillBButton = $ActionPanel/SkillB
onready var UltimateButton = $ActionPanel/Ultimate

#AttackButton.set_button_icon()

#This is used in Resolve()
onready var MovelistTarget = {"Attack":AttackButton,"Defend":DefendButton,"SkillA":SkillAButton,"SkillB":SkillBButton,"Ultimate":UltimateButton}

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicMenu.play_battle_menu()
	randomize()
	
	#UI Stuff
	var ButtonObject = [null,null,null,null,null]
	var UIButton = Directory.new()
	if UIButton.open("res://Textures/CharaSpecificUI/"+Character) == 0:
		for i in range(len(Movelist)):
			if UIButton.file_exists("res://Textures/CharaSpecificUI/"+Character+"/%s.png"%(Movelist[i])):
				ButtonObject[i] = load("res://Textures/CharaSpecificUI/"+Character+"/%s.png"%(Movelist[i]))
				MovelistTarget[Movelist[i]].set_button_icon(ButtonObject[i])
	
	#var AniSprite = AniSpritePackage.instance()
	var PlayerSprite
	var EnemySprite

	if UIButton.file_exists("res://sprites/"+Character+"_Animation.tres") == true:
		PlayerSprite = load("res://sprites/"+Character+"_Animation.tres")
		$PlayerContainer/AnimatedSprite.CharaName = Character
		$PlayerContainer/AnimatedSprite.frames = PlayerSprite
		$PlayerContainer/TextureRect.hide()
		
	if UIButton.file_exists("res://sprites/"+Enemy+"_Animation.tres") == true:
		EnemySprite = load("res://sprites/"+Enemy+"_Animation.tres")
		$EnemyContainer/AnimatedSprite.CharaName = Enemy
		$EnemyContainer/AnimatedSprite.frames = EnemySprite
		$EnemyContainer/TextureRect.hide()
#

	
	#JANKY ANIMATION FIX
	$PlayerContainer/AnimatedSprite.PlayAnimation("Idle")
	$EnemyContainer/AnimatedSprite.PlayAnimation("Idle")
	
	#print_debug("GET THINGAJIGA ",$EnemyContainer/AnimatedSprite.get_sprite_frames())
	
	
	
	AttackButton.connect("mouse_entered",self,"_on_button_select",["Attack"])
	DefendButton.connect("mouse_entered",self,"_on_button_select",["Defend"])
	SkillAButton.connect("mouse_entered",self,"_on_button_select",["SkillA"])
	SkillBButton.connect("mouse_entered",self,"_on_button_select",["SkillB"])
	UltimateButton.connect("mouse_entered",self,"_on_button_select",["Ultimate"])
	
	#click, starts battle???
	AttackButton.connect("button_up",self,"StartTurn",["Attack"])
	DefendButton.connect("button_up",self,"StartTurn",["Defend"])
	SkillAButton.connect("button_up",self,"StartTurn",["SkillA"])
	SkillBButton.connect("button_up",self,"StartTurn",["SkillB"])
	UltimateButton.connect("button_up",self,"StartTurn",["Ultimate"])
	
	#var cooldown = {"Player":{"Attack":0,"Defend":0,"SkillA":0,"SkillB":0,"Ultimate":0},
	#"Enemy":{"Attack":0,"Defend":0,"SkillA":0,"SkillB":0,"Ultimate":0}}
	
	#DEBUGAROO
	CharaDetail = getCharaDetail(CharacterDetailFile) #nanti character name
	EnemyDetail = getCharaDetail(EnemyDetailFile)
	Detail = {"Player":CharaDetail,"Enemy":EnemyDetail}
	
	assert(CharaDetail, "Chara details not found")
	
	UpdateUI()
	#Actuall stuff
	$Textbox.hide()
	$ActionPanel.hide()
	
	display_text("event","Here they come!")
	yield(self,"textbox_closed")
	Resolve()
	$ActionPanel.show()
	
	PlayAnimation("Player","Idle")
	#EffectSquare.name = "Debuffy"
	#$EnemyContainer/VBoxContainer/EffectContainer.add_child(EffectSquare)
	print_debug("End of Setup")

#INPUT STUFF
func _input(_event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_released("left_click")) and $Textbox.visible:
		$Textbox.hide()
		emit_signal("textbox_closed")

#FUTURE DIALOG	
func display_text(dialog,text):
	if dialog == "system":
		$Textbox.anchor_top = 0.7
		$Textbox.anchor_bottom = 0.7
		UpdateUI()
	else:
		$Textbox.anchor_top = 0.05
		$Textbox.anchor_bottom = 0.05
	$Textbox.show()
	$ActionPanel.hide()
	if dialog == "event":
		$Textbox/HBoxContainer/Portrait.hide()
	$Textbox/HBoxContainer/Dialog.text = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	resize()
	#$ActionPanel/HBoxContainer/Actions/PlayerMoves/Attack
	pass

func resize():
	var PlayerSpritePos = Vector2($PlayerContainer/TextureRect.rect_size[0]/2,$PlayerContainer/TextureRect.get_global_position()[1])
	var EnemySpritePos = Vector2(PlayerSpritePos[0]*3,$EnemyContainer/TextureRect.get_global_position()[1])
	$PlayerContainer/AnimatedSprite.set_global_position(PlayerSpritePos)
	$EnemyContainer/AnimatedSprite.set_global_position(EnemySpritePos)
	

#DEBUGAROO
#HOVER AND CHANGE TEXT STUFF
func getCharaDetail(ppath):# -> Array: #nanti character name
	var f = File.new()
	assert(f.file_exists(ppath),"File does not exist!")
	
	f.open(ppath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	#if typeof(output) == TYPE_ARRAY:
	#	return output
	#else:
	#	return[]
	return output

func _on_button_select(button):
	$ActionPanel/Description/Description/VBoxContainer/SkillName.text = CharaDetail[button]["Name"]
	$ActionPanel/Description/Description/VBoxContainer/Desc.text = CharaDetail[button]["Description"]

func display_desc(name,desc):
	$ActionPanel/Description/Description/VBoxContainer/SkillName.text = name
	$ActionPanel/Description/Description/VBoxContainer/Desc.text = desc

func CheckFor(CheckTarget,Effect):
	for i in range(len(CheckTarget["ActiveStatus"])):
		if 	CheckTarget["ActiveStatus"][i].has(Effect):
			return true
	return false

	#ADD ICONS FOR EFFECTS HERE
var UpdateBuffDone = false
func UpdateUI():
	$EnemyContainer/HealthBar.max_value = EnemyDetail["MaxHP"]
	$PlayerContainer/HealthBar.max_value = CharaDetail["MaxHP"]
	$EnemyContainer/HealthBar.value = EnemyDetail["HP"]
	$PlayerContainer/HealthBar.value = CharaDetail["HP"]
	$EnemyContainer/HealthBar/Label.text = ("%s (%s/%s)"%[(EnemyDetail["Name"]),(EnemyDetail["HP"]),(EnemyDetail["MaxHP"])])
	$PlayerContainer/HealthBar/Label.text = ("%s (%s/%s)"%[(CharaDetail["Name"]),(CharaDetail["HP"]),(CharaDetail["MaxHP"])])
	#UPDATE STATUSES
	#Detail = [CharaDetail,EnemyDetail]
	var jj
	
	if UpdateBuffDone == false:
		for j in range(2): #DONT FORGET TO CHANGE THIS TO 2 AGAIN
			jj = 0
			while jj < len(Detail[TurnOrderDef[j]]["ActiveStatus"]):
			
				if Detail[TurnOrderDef[j]]["ActiveStatus"][jj].has("EffectHistory") != true :
					print("Assigning Effect ID ",Detail[TurnOrderDef[j]]["ActiveStatus"][jj].keys()[0])
					Detail[TurnOrderDef[j]]["ActiveStatus"][jj].merge({"EffectHistory":int(EffectHistory)})
					EffectHistory += 1
					pass
			
				EffectInQuestion = Detail[TurnOrderDef[j]]["ActiveStatus"][jj].keys()[0]
				if get_node_or_null((TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(Detail[TurnOrderDef[j]]["ActiveStatus"][jj]["EffectHistory"])))) != null:
					pass
				else: #CREATE NEW BUFF ICON THING
					
					if Detail[TurnOrderDef[j]]["ActiveStatus"][jj][EffectInQuestion]["Duration"] != 0:
						var EffectSquare = EffectSquarePackage.instance()
						EffectSquare.name = EffectInQuestion+("_%s"%Detail[TurnOrderDef[j]]["ActiveStatus"][jj]["EffectHistory"])
						EffectSquare.EffectHistory = Detail[TurnOrderDef[j]]["ActiveStatus"][jj]["EffectHistory"]
						if Detail[TurnOrderDef[j]]["ActiveStatus"][jj][EffectInQuestion].has("Ammount"):
							EffectSquare.get_child(0).text = (EffectInQuestion+"\n"+str(Detail[TurnOrderDef[j]]["ActiveStatus"][jj][EffectInQuestion]["Ammount"]*100)+"%"+"|%d Turns" %(Detail[TurnOrderDef[j]]["ActiveStatus"][jj][EffectInQuestion]["Duration"]))
						else:
							EffectSquare.get_child(0).text = (EffectInQuestion+"\n"+"%d Turns" %(Detail[TurnOrderDef[j]]["ActiveStatus"][jj][EffectInQuestion]["Duration"]))
						get_node(TurnOrderDef[j]+"Container/EffectContainer").add_child(EffectSquare)
						Detail[TurnOrderDef[j]]["ActiveStatus"][jj][EffectInQuestion]["Duration"] += 1
						#CharaDetail["ActiveStatus"].keys()[i]
					
				jj += 1
		#UpdateBuffDone = true
	#UPDATE DEATH CLOCK
			if Detail[TurnOrderDef[j]].has("DeathClock") and get_node_or_null(TurnOrderDef[j]+"Container/EffectContainer/DEATH") == null:
				var EffectSquare = EffectSquarePackage.instance()
				EffectSquare.name = "DEATH"
				EffectSquare.get_child(0).text = ("DEATH\n%d Turns"%(Detail[TurnOrderDef[j]]["DeathClock"]))
				get_node(TurnOrderDef[j]+"Container/EffectContainer").add_child(EffectSquare)

func PlayAnimation(AniTarget,move):
	var AniSprite
	if typeof(AniTarget) == TYPE_DICTIONARY:
		if AniTarget.values() == CharaDetail.values():
			AniSprite = $PlayerContainer/AnimatedSprite
		else:
			AniSprite = $EnemyContainer/AnimatedSprite
	elif AniTarget == "Player":
		AniSprite = $PlayerContainer/AnimatedSprite
	else:
		AniSprite = $EnemyContainer/AnimatedSprite
	
	$PlayerContainer/AnimatedSprite.connect("animation_finished",$PlayerContainer/AnimatedSprite,"PlayAnimation",["Idle"],CONNECT_ONESHOT)
	$EnemyContainer/AnimatedSprite.connect("animation_finished",$EnemyContainer/AnimatedSprite,"PlayAnimation",["Idle"],CONNECT_ONESHOT)
	
	AniSprite.set_frame(0)
	AniSprite.PlayAnimation(move)
	pass

	#update CD timers and stuff???
func Resolve():
	#check death
	if CharaDetail.has("DeathClock"):
		
		CharaDetail["DeathClock"] = clamp(CharaDetail["DeathClock"]-1,0,5)
		print_debug(CharaDetail["DeathClock"]," Death clockce")
		if CharaDetail["DeathClock"] <= 0:
			print_debug("DEATHCHECK DEATHCHECK")
			if CharaDetail.has("AntiDeathEffect"):
				if CharaDetail["AntiDeathEffect"].size() != 0:
					CharaDetail["DeathClock"] += 3
					CharaDetail["AntiDeathEffect"].clear()
					display_text("system","You have cheated death!\nBut it still awaits")
					yield(self,"textbox_closed")
				else:
					Victory = true
					print_debug("you lose")
					PlayerLose()
					pass
			else:
				Victory = true
				print_debug("you lose")
				PlayerLose()
				pass
		$PlayerContainer/EffectContainer/DEATH/Label.text = ("DEATH\n%d Turns"%(CharaDetail["DeathClock"]))

	if CharaDetail.has("AntiDeathEffect"):
		CharaDetail["AntiDeathEffect"].clear()

	if EnemyDetail.has("DeathClock"):
		EnemyDetail["DeathClock"] = clamp(EnemyDetail["DeathClock"]-1,0,5)
		if EnemyDetail["DeathClock"] <= 0:
			if EnemyDetail.has("AntiDeathEffect"):
				if EnemyDetail["AntiDeathEffect"].size() != 0:
					EnemyDetail["DeathClock"] += 3
					EnemyDetail["AntiDeathEffect"].clear()
					display_text("system",("%s have cheated death!\nBut it still awaits"%(EnemyDetail["Name"])))
					yield(self,"textbox_closed")
				else:
					Victory = true
					print_debug("you win")
					PlayerWin()
					pass
			else:
				Victory = true
				print_debug("you win")
				PlayerWin()
				pass
		$EnemyContainer/EffectContainer/DEATH/Label.text = ("DEATH\n%d Turns"%(EnemyDetail["DeathClock"]))
	
	if EnemyDetail.has("AntiDeathEffect"):
		EnemyDetail["AntiDeathEffect"].clear()
		
	#UPDATE COOLDOWNS
	print_debug("Start resolve")
	#print_debug(MovelistTarget[Movelist[0]].get_child(0)) the first child, which happens to be CD_Display
	for i in range(len(Movelist)):
		#print_debug(CharaDetail["ActiveCD"][Movelist[i]])
		if CharaDetail["ActiveCD"][Movelist[i]] > 0:
			#print_debug("Updating",Movelist[i])
			MovelistTarget[Movelist[i]].get_child(0).show()
			MovelistTarget[Movelist[i]].get_child(0).text = "CD: %d turns" %CharaDetail["ActiveCD"][Movelist[i]]
			CharaDetail["ActiveCD"][Movelist[i]] -= 1
			MovelistTarget[Movelist[i]].disabled = true
		else:
			MovelistTarget[Movelist[i]].get_child(0).hide()
			if CharaDetail[Movelist[i]].has("Uses"):
				MovelistTarget[Movelist[i]].get_child(0).show()
				MovelistTarget[Movelist[i]].get_child(0).text = "%d Left" %(CharaDetail[Movelist[i]]["Uses"])
				
			MovelistTarget[Movelist[i]].disabled = false
			
		if EnemyDetail["ActiveCD"][Movelist[i]] > 0:
			#print_debug("Updating",Movelist[i])
			EnemyDetail["ActiveCD"][Movelist[i]] -= 1
	
	#UPDATE STATUSES
	for j in range(2):
		print_debug("Resolve status "+TurnOrderDef[j])
		print_debug(Detail[TurnOrderDef[j]]["ActiveStatus"])
		var m = 0
		
		while true and len(Detail[TurnOrderDef[j]]["ActiveStatus"]) != 0:
			EffectInQuestion = Detail[TurnOrderDef[j]]["ActiveStatus"][m].keys()[0]
					
			print_debug("Currently checking/using ",Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion])
			if Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion]["Duration"] > 0:
				Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion]["Duration"] -= 1
				

				CurrentEffectHistory = Detail[TurnOrderDef[j]]["ActiveStatus"][m]["EffectHistory"]
				#var CurrentEffectLabelName = Detail[TurnOrderDef[j]]["ActiveStatus"][m]
				if Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion]["Duration"] == 0:
					print_debug("REMOVING ",Detail[TurnOrderDef[j]]["ActiveStatus"][m])
					if get_node_or_null(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(CurrentEffectHistory))) != null:
						get_node(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(CurrentEffectHistory))).queue_free()
					Detail[TurnOrderDef[j]]["ActiveStatus"].remove(m)
					m -= 1
					
				else:
					#print_debug("double debug bros",Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion].has("Duration"))
					if Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion].has("Ammount") == true:
						get_node(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(CurrentEffectHistory))+"/Label").text = (EffectInQuestion+"\n"+str(Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion]["Ammount"]*100)+"%"+"|%d Turns" %(Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion]["Duration"]))	
					else:
						get_node(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(CurrentEffectHistory))+"/Label").text = (EffectInQuestion+"\n"+"%d Turns" %(Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion]["Duration"]))
					
				
			else:
				print_debug("END OF TURN REMOVAL OF ",Detail[TurnOrderDef[j]]["ActiveStatus"][m])
				if get_node_or_null(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(Detail[TurnOrderDef[j]]["ActiveStatus"][m]["EffectHistory"]))) != null:
					get_node(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(Detail[TurnOrderDef[j]]["ActiveStatus"][m]["EffectHistory"]))).queue_free()
				Detail[TurnOrderDef[j]]["ActiveStatus"].remove(m)
				m -= 1
				
			print_debug("End of loopdeloop")
			m += 1
			if m == len(Detail[TurnOrderDef[j]]["ActiveStatus"]):
				print_debug("moredacie ",Detail[TurnOrderDef[j]]["ActiveStatus"])
				break
	
	#print_debug("CharaStatus",CharaDetail["SkillB"]["Effect"])
	#pass
	
	
	#i decided to put the effects into an array to have custom order?
	#might be dumb idk
	
#func UpdateCD(Target):
#	var Target

func RandomEffectCheck():
	for j in range(2):
		var mm = 0
		while mm < len(Detail[TurnOrderDef[j]]["ActiveStatus"]):
			if "RANDOM_EFFECT" in Detail[TurnOrderDef[j]]["ActiveStatus"][mm].keys():
				print_debug("RANDOM EFFECT TIME")
				print_debug("CHOICES ",Detail[TurnOrderDef[j]]["ActiveStatus"][mm]["RANDOM_EFFECT"]["Choice"])
				var choices = len(Detail[TurnOrderDef[j]]["ActiveStatus"][mm]["RANDOM_EFFECT"]["Choice"])
				choices = randi()%choices
				var chosen = Detail[TurnOrderDef[j]]["ActiveStatus"][mm]["RANDOM_EFFECT"]["Choice"].duplicate(true)[choices]
				print_debug(chosen)
				#chosen[chosen.keys()[0]]["Duration"] -= 1
				Detail[TurnOrderDef[j]]["ActiveStatus"].push_front(chosen)
				print_debug(Detail[TurnOrderDef[j]]["ActiveStatus"])
				mm += 1
				
#			if Detail[TurnOrderDef[j]]["ActiveStatus"][mm].has("EffectHistory"):
#				var GetName
#				for i in range(len(Detail[TurnOrderDef[j]]["ActiveStatus"][mm])):
#					if Detail[TurnOrderDef[j]]["ActiveStatus"][mm].keys()[i] != "EffectHistory":
#						GetName = Detail[TurnOrderDef[j]]["ActiveStatus"][mm].keys()[i]
#				print_debug(Detail[TurnOrderDef[j]]["ActiveStatus"][mm])
#				#Detail[TurnOrderDef[j]]["ActiveStatus"][m][EffectInQuestion]["Duration"]
#				if Detail[TurnOrderDef[j]]["ActiveStatus"][mm][GetName]["Duration"] == 0:
#					if get_node_or_null(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(Detail[TurnOrderDef[j]]["ActiveStatus"][mm]["EffectHistory"]))) != null :
#						get_node(TurnOrderDef[j]+"Container/EffectContainer/"+EffectInQuestion+("_%s"%(Detail[TurnOrderDef[j]]["ActiveStatus"][mm]["EffectHistory"]))).queue_free()
#					Detail[TurnOrderDef[j]]["ActiveStatus"].remove(mm)
#					mm-=1
			mm += 1

func StartTurn(PlayerMove): #for deciding which character goes first
	
	#print_debug("Start turn "+str(TurnCount+1))
	
	
	EnemyMove = EnemyGenerateMove()
	if ((CharaDetail[PlayerMove]["Priority"] == true) and (EnemyDetail[EnemyMove]["Priority"] == false)) or CharaDetail[PlayerMove].has("Crit_Prio"):
		TurnOrder = ["Player","Enemy"]
	elif ((EnemyDetail[EnemyMove]["Priority"] == true) and (CharaDetail[PlayerMove]["Priority"] == false)) or EnemyDetail[EnemyMove].has("Crit_Prio"):
		TurnOrder = ["Enemy","Player"]
	elif TurnCount == 0: #swap turns
		TurnOrder = TurnOrderDef
	else:
		TurnOrder.invert()
	
	print_debug(str(TurnOrder)+" Enemy move: "+EnemyMove+" Player Move: "+PlayerMove)
	
	TurnProgress = 0
	while TurnProgress in range(2) and not Victory:
		
		RandBuffGiven = false
		print_debug("Start",TurnOrder[TurnProgress],"Turn")
		if TurnOrder[TurnProgress] == "Player" and not Victory:
			#print_debug("Player phase here")
			$PlayerContainer/TextureRect.rect_scale *= 2
			Phase(CharaDetail,EnemyDetail,PlayerMove)
			yield(self,"phase_over")
			if CheckFor(CharaDetail,"DOUBLE_TURN"):
				display_text("system","Double move!")
				yield(self,"textbox_closed")
				Phase(CharaDetail,EnemyDetail,PlayerMove)
				yield(self,"phase_over")
			$PlayerContainer/TextureRect.rect_scale /= 2
		elif TurnOrder[TurnProgress] == "Enemy" and not Victory:
			#print_debug("Enemy phase here")
			$EnemyContainer/TextureRect.rect_scale *= 2
			Phase(EnemyDetail,CharaDetail,EnemyMove)
			yield(self,"phase_over")
			if CheckFor(EnemyDetail,"DOUBLE_TURN"):
				display_text("system","Double move!")
				yield(self,"textbox_closed")
				Phase(EnemyDetail,CharaDetail,EnemyMove)
				yield(self,"phase_over")
			$EnemyContainer/TextureRect.rect_scale /= 2
		var CurrentEffectHistory
		TurnProgress += 1
		

	if Victory: #FightPhaseEnd
		if CharaDetail["HP"] > 0:
			print_debug("WIN")
			PlayerWin()
			pass
		else:
			print_debug("LOSE")
			PlayerLose()
			pass
		pass
	else:
		pass
	Resolve()
	RandomEffectCheck()
	UpdateUI()
	
	TurnCount += 1
	#print_debug(CharaDetail["ActiveStatus"])
	#print_debug("Resolve Time")
	

#FightPhaseEnd
func PlayerWin():
	MusicMenu.stop_battle_menu()
	display_text("event","You won!")
	yield(self,"textbox_closed")
	get_tree().change_scene("res://win_sf_jalur_bc.tscn")
	pass #placeholder, delete later/put at bottom

func PlayerLose():
	MusicMenu.stop_battle_menu()
	display_text("event","You lost...")
	yield(self,"textbox_closed")
	get_tree().change_scene("res://lose_sf_jalur_bc.tscn")
	pass #placeholder, delete later/put at bottom

var EnemyPossibleMoveset = []
func EnemyGenerateMove():	
	EnemyPossibleMoveset.clear()
	if EnemyDetail["ActiveCD"]["Attack"] == 0:
		for i in range(3):
			EnemyPossibleMoveset.push_back("Attack")
	if EnemyDetail["ActiveCD"]["Defend"] == 0:
		for i in range(3):
			EnemyPossibleMoveset.push_back("Defend")
	if EnemyDetail["ActiveCD"]["SkillA"] == 0:
		for i in range(2):
			EnemyPossibleMoveset.push_back("SkillA")
	if EnemyDetail["ActiveCD"]["SkillB"] == 0:
		for i in range(2):
			EnemyPossibleMoveset.push_back("SkillB")
	if EnemyDetail["ActiveCD"]["Ultimate"] == 0:
		for i in range(1):
			EnemyPossibleMoveset.push_back("Ultimate")
	#DEBUGTIME
	return EnemyPossibleMoveset[randi()%len(EnemyPossibleMoveset)]
	pass 

#Actor is the (Detail) character that moves, X is the chosen move
func Phase(Actor,Receiver,move):
	
	PlayAnimation(Actor,move)
	display_text("system",(Actor["Name"]+" used "+ Actor[move]["Name"]+"(%s)"%move))
	yield(self,"textbox_closed")
	
	var EffectCount = len(Actor[move]["Effect"])
	for i in range(EffectCount):
		#ATK
		if "ATK" in Actor[move]["Effect"][i]:
			
			PlayAnimation(Receiver,"Hurt")
			
			AttackDamage = Actor[move]["Effect"][i]["ATK"]
			#Check for DMG reducing effects
			##print_debug("Checking DMG RED effects on "+Receiver["Name"])
			
			for k in range(len(Actor["ActiveStatus"])):
				if Actor["ActiveStatus"][k].has("AMP_ATK"):
					AttackDamage = ceil(AttackDamage*Actor["ActiveStatus"][k]["AMP_ATK"]["Ammount"])
			
			for k in range(len(Receiver["ActiveStatus"])):
				if Receiver["ActiveStatus"][k].has("DMG_RED"):
					##print_debug(Receiver["Name"]+" has DMG RED, retalitating.")
					AttackDamage = floor(AttackDamage*Receiver["ActiveStatus"][k]["DMG_RED"]["Ammount"])
				
			var collective_crit_chance = 0
			if "Crit" in Actor[move]["Effect"][i]:
				collective_crit_chance += Actor[move]["Effect"][i]["Crit"]
			#CRIT_BUFF CHECK
			for k in range(len(Actor["ActiveStatus"])):
				if Actor["ActiveStatus"][k].has("CRIT_BUFF"):
					collective_crit_chance += Actor["ActiveStatus"][k]["CRIT_BUFF"]["Ammount"]
			
			if collective_crit_chance > 0:
				var d100roll = (randi() % 100 + 1)
				if d100roll <= (collective_crit_chance*100):
					display_text("system","CRITICAL HIT!!!")
					yield(self,"textbox_closed")
					AttackDamage *= 2
			
			for k in range(len(Receiver["ActiveStatus"])):
				if Receiver["ActiveStatus"][k].has("DODGE"):
					var d100roll = (randi() % 100 + 1)
					if d100roll <=  Receiver["ActiveStatus"][k]["DODGE"]["Ammount"]*100:
						AttackDamage *= 0
						display_text("system",(Actor["Name"]+" Missed!!!"))
						yield(self,"textbox_closed")

			Receiver["HP"] -= AttackDamage
			display_text("system",(Actor["Name"]+" dealt "+str(AttackDamage)+" damage to "+Receiver["Name"]+"!"))
			yield(self,"textbox_closed")						
		
		#HEAL

		if "HEAL" in Actor[move]["Effect"][i]:
			#print_debug("heal")
			Actor["HP"] = clamp(Actor[move]["Effect"][i]["HEAL"]+Actor["HP"],0,Actor["MaxHP"])
			display_text("system",(Actor["Name"]+" restored "+str(Actor[move]["Effect"][i]["HEAL"])+" HP!"))
			yield(self,"textbox_closed")
		
		#BUFFS
		#DMG RED
		if "DMG_RED" in Actor[move]["Effect"][i]:
			Actor["ActiveStatus"].push_back({"DMG_RED":(Actor[move]["Effect"][i].duplicate(true).get("DMG_RED"))})#{"DMG_RED":Actor[move]["Effect"][i]["DMG_RED"]}
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Actor["Name"]+" takes "+str(Actor[move]["Effect"][i]["DMG_RED"]["Ammount"]*100)+"% Damage"))
			yield(self,"textbox_closed")
		
		if "DODGE" in Actor[move]["Effect"][i]:
			Actor["ActiveStatus"].push_back({"DODGE":(Actor[move]["Effect"][i].duplicate(true).get("DODGE"))})#{"DMG_RED":Actor[move]["Effect"][i]["DMG_RED"]}
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Receiver["Name"]+" now has "+str(Actor[move]["Effect"][i]["DODGE"]["Ammount"]*100)+"% chance to miss!"))
			yield(self,"textbox_closed")
		
		if "DOUBLE_TURN" in Actor[move]["Effect"][i]:
			Actor["ActiveStatus"].push_back({"DOUBLE_TURN":(Actor[move]["Effect"][i].duplicate(true).get("DOUBLE_TURN"))})#{"DMG_RED":Actor[move]["Effect"][i]["DMG_RED"]}
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Actor["Name"]+" next action will go twice!"))
			yield(self,"textbox_closed")
			
		if "AMP_ATK" in Actor[move]["Effect"][i]:
			Actor["ActiveStatus"].push_back({"AMP_ATK":(Actor[move]["Effect"][i].duplicate(true).get("AMP_ATK"))})#{"DMG_RED":Actor[move]["Effect"][i]["DMG_RED"]}
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Actor["Name"]+" gained attack amplification!"))
			yield(self,"textbox_closed")
			
		#if "DMG_NULL" in Actor[move]["Effect"][i]:
		#	pass
		
		if "CRIT_BUFF" in Actor[move]["Effect"][i]:
			Actor["ActiveStatus"].push_back({"CRIT_BUFF":(Actor[move]["Effect"][i].duplicate(true).get("CRIT_BUFF"))})#{"DMG_RED":Actor[move]["Effect"][i]["DMG_RED"]}
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Actor["Name"]+" gained "+str(Actor[move]["Effect"][i]["CRIT_BUFF"]["Ammount"]*100)+"% Crit chance"))
			yield(self,"textbox_closed")
			
		if "DEATH" in Actor[move]["Effect"][i]:
			if not Actor.has("DeathClock"):
				Actor.merge({"DeathClock":(Actor[move]["Effect"][i]["DEATH"]["Duration"]+1)})
			else:
				Actor["DeathClock"] += 2
			#Actor["ActiveStatus"].push_back({"DEATH":(Actor[move]["Effect"][i].duplicate(true).get("DEATH"))})#{"DMG_RED":Actor[move]["Effect"][i]["DMG_RED"]}
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Actor["Name"]+" will die in "+str(Actor["DeathClock"])+" Turns"))
			yield(self,"textbox_closed")
			
		if "RANDOM_EFFECT" in Actor[move]["Effect"][i]:
			Actor["ActiveStatus"].push_back({"RANDOM_EFFECT":(Actor[move]["Effect"][i].duplicate(true).get("RANDOM_EFFECT"))})#{"DMG_RED":Actor[move]["Effect"][i]["DMG_RED"]}
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Actor["Name"]+" gained a random effect!"))
			yield(self,"textbox_closed")
			
			
		if "ANTI_DEATH" in Actor[move]["Effect"][i]:
			Actor["AntiDeathEffect"].push_back(Actor[move]["Effect"][i]["ANTI_DEATH"])
			#Actor["ActiveStatus"].erase("Anim")
			display_text("system",(Actor["Name"]+" attempts to cheat death!"))
			yield(self,"textbox_closed")
		
	#End of effects n shit
	print_debug("End of"+Actor["Name"]+"phase")
	#Apply cooldown
	Actor["ActiveCD"][move] += Actor[move]["CD"]
	if Actor[move].has("Uses"):
		Actor[move]["Uses"] -= 1
	UpdateBuffDone = false
		
	if Receiver["HP"] <= 0:
		if Receiver.has("AntiDeathEffect"):
			if Receiver["AntiDeathEffect"].size() != 0:
				Receiver["HP"] += AttackDamage
				Receiver["AntiDeathEffect"].clear()
				display_text("system",(Receiver["Name"]+" cheated death!"))
				yield(self,"textbox_closed")
				pass
			else:
				Victory = true
		else:
			Victory = true
			pass
	
	#end of turn
	$Textbox.hide()
	$ActionPanel.show()
	emit_signal("phase_over")
	
