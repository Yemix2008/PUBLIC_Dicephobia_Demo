extends Node3D

# PREFABS

const diePrefab = preload("res://prefabs/DiePrefab/DiePrefab.tscn")
const buttonPrefab = preload("res://prefabs/ButtonPrefab/ButtonPrefab.tscn")

#ANIMATIONS

const gameOverLayer = preload("res://animation/gameOverLayer.gd")

#TEXTURES

const placeHolderPNG = preload("res://images/placeHolder.svg")

const d2PNG = preload("res://images/Dice/Logo/D2.png")
const d4PNG = preload("res://images/Dice/Logo/D4.png")
const d6PNG = preload("res://images/Dice/Logo/D6.png")
const d10PNG = preload("res://images/Dice/Logo/D10.png")
const d20PNG = preload("res://images/Dice/Logo/D20.png")

const agoraphobiePNG = preload("res://images/Fears/Agoraphobie.png")
const atychiphobiePNG = preload("res://images/Fears/Atychiphobie.png")
const cataptrophobiePNG = preload("res://images/Fears/Cataptrophobie.png")
const koinophobiePNG = preload("res://images/Fears/Koinophobie.png")
const nihilophobiePNG = preload("res://images/Fears/Nihilophobie.png")
const peniaphobiePNG = preload("res://images/Fears/Peniaphobie.png")

const dicephobiePNG = preload("res://images/Fears/Dicephobie.png")

# ENCYCLOPEDIA

var All={
	"Prefabs":
		{
		"Die":diePrefab,
		"Button":buttonPrefab
		},
	"Encyclopedia":
		{
		"Fear":
			{
			"Peniaphobie":{"Name":"Peniaphobie", "Text":"Peur d'être Dépouillé,\nvotre phobie vous fait\nperdre de plus en plus\nd'argent à chaque\nlancer", "Color":Color(1.0,0.5,0.0), "Texture":peniaphobiePNG}, 
			"Agoraphobie":{"Name":"Agoraphobie", "Text":"Peur des Foules,\nvotre phobie vous\nempêche de lancer\nplus de 2 dés", "Color":Color(0.0, 1.0, 0.3), "Texture":agoraphobiePNG},
			"Atychiphobie":{"Name":"Atychiphobie", "Text":"Peur de l'Échec,\nvotre phobie renforce\nsa propre ténacité", "Color":Color(1.0,0.0,0.0), "Texture":atychiphobiePNG},
			"Cataptrophobie":{"Name":"Cataptrophobie", "Text":"Peur des Miroirs,\nvotre phobie empêche\ntout score de compter\n si une paire,\ndouble paire\nou carré est joué", "Color":Color(0.45, 0.325, 1.0), "Texture":cataptrophobiePNG},
			"Koinophobie":{"Name":"Koinophobie", "Text":"Peur de l'Ordinaire,\nvotre phobie empêche\n tout score de compter\nsans combinaison", "Color":Color(0.2, 0.4, 0.7), "Texture":koinophobiePNG},
			"Nihilophobie":{"Name":"Nihilophobie", "Text":"Peur du Néant,\nvotre phobie annihile\nvotre 1er, 3e, 5e\nlancers etc..", "Color":Color(0.1, 0.1, 0.1), "Texture":nihilophobiePNG}
			},
		"Blank":
			{
			"D2":{"Nom":"D2","NbFace":2,"Prix":2},
			"D4":{"Nom":"D4","NbFace":4,"Prix":2},
			"D6":{"Nom":"D6","NbFace":6,"Prix":3},
			"D10":{"Nom":"D10","NbFace":10,"Prix":5},
			"D20":{"Nom":"D20","NbFace":20,"Prix":10}
			},
		"Morph":
			{
			"Ultrakill":{"Nom":"Ultrakill","Prix":2, "NbFace":2 ,"Text":"Ajoute 1 au mult\ns'il score 2 sinon\nil score 0"},
			"Joker":{"Nom":"Joker","Prix":2, "NbFace":4 ,"Text":"Annule la règle\nde la peur pour le\nprochain lancer\ns'il score 4"},
			"R. Dechu":{"Nom":"R. Dechu","Prix":5,"NbFace":6 ,"Text":"Copie le score du\ndé à sa gauche"},
			"Holy Gr.":{"Nom":"Holy Gr.","Prix":1,"NbFace":10 ,"Text":"Score 10 mais\ns'autodétruit"}
			},
		"Augment":
			{
			"OR":{"Nom":"OR", "Prix":1},
			"CRISTAL":{"Nom":"CRISTAL", "Prix":1},
			"VOID":{"Nom":"VOID", "Prix":2}
			},
		"Passive":
			{
			#"AnotherOne":{"Nom":"AnotherOne", "Img":"", "Prix":9},
			#"RefusDeLaMort":{"Nom":"RefusDeLaMort", "Img":"", "Prix":9}
			}
		}
	}

var diceInGame: Dictionary = {} # Dé(s) dans le Jeu
var buttonInGame: Dictionary = {} # Bouton(s) dans le Jeu

# PLAYER

var mousePos = Vector2() # Position de la Souris
var QRtime: float = 0 # Temps de Pression du Quick Restart
var targetedDie: DieData = null # Dé Ciblé
var toUntargetDice: Array = [] # Dé(s) à Décilbé(s)
var diceHand: Array = [] # Dé(s) Possédé(s)
var diceInventory: Array = [] # Dé(s) Possédé(s) mais Non Affiché
var dicePlayed: Array = [] # Dé(s) en Jeu
var diePlayedInShop : Array = [] # Dé en Jeu dans le Shop
var diceSorted: Array = [] # Dé(s) en Jeu Trié(s)
var rollNum: int = 0 # Nombre de Lancé ce Tour
var rolls: Dictionary = {} # Dé(s) Lancé(s) -> Résultat(s)
var rollsSorted: Array = [] # Résultat Trié dans l'ordre Croissant
var jokerCountdown: int = 0 # Est ce que le dé joker est actif
var viegoCrown = null # Copie du dé de gauche (morph viego le goat)

var score: int = 0 # Score
var mult: int = 1 # Multiplicateur de Score
var comb: Dictionary = {} # Main Obtenu

@export var playerGold: int = 3 # Argent du Joueur

# SHOP

var isShopping: bool = false # Le Shop est-il Actif  ?
@export var shop: Dictionary = {
	"Blanks":[], # Dé(s) Vierge(s) dans le Shop
	"Morphs":[], # Dé(s) Altéré(s) dans le Shop
	"Augment":"", # Amélioration de Face dans le Shop
	"Passif":"" # Passif dans le Shop
}

# FEAR

var allFears: Array = [] # Toutes les Peurs de la Run
var fearNum: int = 0 # Numéro de la Peur Actuelle (0)
var fearMaxHealth: int = 0 # Vie Maximale de la Peur
var fearCurrentHealth: int = 0 # Vie Actuel de la Peur

# TOOLS

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func RNG(source, type: String, amount: int): # Tire au Sort (amount) élément(s) dans la (source) de type (type)
	var result = []
	var RNGsource = source.duplicate()
	
	if type == "List":
		RNGsource.shuffle()
		
		for i in range(min(amount, len(RNGsource))):
			result.append(RNGsource[i])
	elif type == "Dictionnary":
		var RNGkeys = RNGsource.keys()
		RNGkeys.shuffle()
		
		for i in range(min(amount, RNGkeys.size())):
			result.append(RNGsource[RNGkeys[i]])
	
	return result

func createDie(dieName: String, dieMorph: String, dieSides: Array, dieAugment: Array, diePrice: int, diceList: Array): # Créé un Dé avec les charactéristiques (name, morph, sides, augment, price) et le Sauvegarde dans (diceList) 
	var dieData: DieData = DieData.new()
	dieData.name = dieName
	dieData.morph = dieMorph
	dieData.sides = dieSides
	dieData.augment = dieAugment
	dieData.price = diePrice
	diceList.append(dieData)

func spawnDice(diceList: Array): # Fait apparaitre tous les Dés Sauvegardés dans (diceList)
	var index = 0
	for dieData in diceList:
		var die = All["Prefabs"]["Die"].instantiate()
		if diceList == diceHand or diceList == diceInventory: add_child(die)
		else: $World/Boards/Center/Shop.add_child(die)
		diceInGame[dieData] = die
		die.global_transform.origin = Vector3(-16.75, 0.9, -7.0 + index * 2) if (diceList == diceHand) else Vector3(1.55 + index * 2, -1, 2.3) if (diceList == shop["Blanks"]) else Vector3(2 + index * 3.15, -0.955, -0.53) if (diceList == shop["Morphs"]) else Vector3(100,0.4,0)
		die.InitializeDie(self, dieData, index)
		index += 1

func moveDie(dieToMove: DieData, fromDiceList: Array, toDiceList: Array): # Déplacer/Acheter un Dé
	var dieStatus: String = "Own" if (fromDiceList == diceHand or fromDiceList == dicePlayed or fromDiceList == diePlayedInShop) else "Bought" if (fromDiceList == shop["Blanks"] or fromDiceList == shop["Morphs"]) else "Given"
	
	if dieStatus == "Own": fromDiceList.erase(dieToMove) # Retirer de la Source
	elif dieStatus == "Bought":
		fromDiceList[fromDiceList.find(dieToMove)] = null
		playerGold -= dieToMove.price
		valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.3)
		diceInGame[dieToMove].ShowLabel("Price", "")
	
	toDiceList.append(dieToMove) # Ajouter de la Destination
	diceInGame[dieToMove].index = len(toDiceList) - 1 
	
	if toDiceList == diceHand: # Positionner
		diceInGame[dieToMove].position = Vector3(-16.75, diceInGame[dieToMove].position.y + 0.9 if fromDiceList == dicePlayed else diceInGame[dieToMove].position.y + 0.3, -7 + 2*(len(diceHand) - 1))
		if diceInGame[dieToMove].get_parent() != self: diceInGame[dieToMove].reparent(self)
	elif toDiceList == dicePlayed: diceInGame[dieToMove].position = Vector3(-5.5 + 2*(len(toDiceList) - 1), diceInGame[dieToMove].position.y - 0.9, 7)
	elif toDiceList == diePlayedInShop: diceInGame[dieToMove].position = Vector3(-1.875, diceInGame[dieToMove].position.y - 0.9, 7)
	elif toDiceList == diceSorted: diceInGame[dieToMove].position = Vector3((1 - (len(fromDiceList) + len(toDiceList))) + 2*(len(toDiceList) - 1), diceInGame[dieToMove].position.y + 1.1, 0)
	
	if dieStatus == "Own" and toDiceList != diceSorted: for dieData in fromDiceList: diceInGame[dieData].OrderDie(fromDiceList) # Réordonner

func revealDice(diceList: Array, secUntilDrop: float, secUntilNext: float):
	for die in diceList:
		diceInGame[die].show()
		if secUntilDrop != 0: await wait(secUntilDrop)
		diceInGame[die].PlayAnimation("Untargeted", ["Targeted"])
		if diceList == diceSorted:
			await wait(0.1)
			diceInGame[die].ShowLabel("Score", str(1))
			valueAnimation(diceInGame[die].get_node("ScoreLabel"),0 if die.morph == "Ultrakill" else 1,rolls[die],0.2) 
			valueAnimation($GUI/ScoreDie1/Score1,score,score+rolls[die]*2 if (die.augment[0] == "Cristal" and die.augment[1] >= rolls[die]) else score+rolls[die],0.8)
			if die.augment[0] == "Or" and die.augment[1] >= rolls[die]: valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,playerGold,playerGold+rolls[die],0.4)
			if die.morph == "Joker" and rolls[die] == 4: jokerCountdown = 2
			if comb.has(diceList.find(die)):
				await wait(0.2)
				$GUI/Comb.text = comb[diceList.find(die)] + " !"
				await slideAnimation($GUI/Comb, "Décélération", "x", 0, -2.5, 12, 0.012)
				await slideAnimation($GUI/Comb, "Accélération", "x", -2.5, 9.75 if $GUI/Comb.text == "Suite !" else 9.4 if $GUI/Comb.text == "Carré !" else 8.1 if $GUI/Comb.text == "Brelan !" else 9.65 if $GUI/Comb.text == "Paire !" else 4.1 if $GUI/Comb.text == "Double Paire !" else -2.5, 8, 0.008)
				if die.morph == "Ultrakill": mult+=1
				if $GUI/Comb.text == "Paire !" or $GUI/Comb.text == "Double Paire !" or $GUI/Comb.text == "Carré !": 
					if allFears[fearNum]["Name"] == "Cataptrophobie" and jokerCountdown != 1: mult = 0
					else: mult += 2 if (allFears[fearNum]["Name"] == "Koinophobie" and mult == 0 and jokerCountdown != 1) else 1
				elif $GUI/Comb.text == "Brelan !": mult += 2 if (allFears[fearNum]["Name"] == "Cataptrophobie" and jokerCountdown != 1) else 1
				elif $GUI/Comb.text == "Suite !": mult += diceSorted.size() if (allFears[fearNum]["Name"] == "Koinophobie" and mult == 0 and jokerCountdown != 1) else diceSorted.size() - 1 
				$GUI/MultDie/Mult.text = "x" + str(mult)
				$GUI/Comb.position.x = 0
				$GUI/Comb.text = ""
			score += rolls[die]*2 if (die.augment[0] == "Cristal" and die.augment[1] >= rolls[die]) else rolls[die]
			playerGold += rolls[die] if (die.augment[0] == "Or" and die.augment[1] >= rolls[die]) else 0
		if secUntilNext != 0: await wait(secUntilNext)
		if die.morph == "Holy Gr.":
			diceSorted.erase(die)
			diceInGame[die].queue_free()
			diceInGame.erase(die)
		if jokerCountdown > 0: jokerCountdown-=1	
		if die.morph == "R. Dechu" and viegoCrown != null : viegoCrown = null
		
func actualizeDicePrice():
	for dieData in diceInGame:
		if playerGold < int(dieData.price): diceInGame[dieData].get_node("PriceLabel").modulate = Color(1.0, 0.0, 0.0) # Mets le Prix en Rouge si Trop Cher, ou en Jaune dans le cas Contraire
		else: diceInGame[dieData].get_node("PriceLabel").modulate = Color(0.925, 0.918, 0.0)

func applyMorph(die):
	if diePlayedInShop == [] or diePlayedInShop[0].morph != "Normale" or len(diePlayedInShop[0].sides) != len(targetedDie.sides): return
	else:
		playerGold -= die.price
		diePlayedInShop[0].morph = die.morph
		if toUntargetDice.has(die): toUntargetDice.erase(die)
		shop["Morphs"].erase(die)
		diceInGame[die].queue_free()
		diceInGame.erase(die)
		

func createPassive(passiveName: String, passivePrice: String):
	var passiveData: PassiveData = PassiveData.new()
	passiveData.name = passiveName
	passiveData.price = passivePrice

func target(type: String): # Obtient les Infos d'un Élément du Type Souhaité (type) Ciblé
	var space = get_world_3d().direct_space_state
	var camera = $Cameras/BalatroView if $Cameras/BalatroView.is_current() else $Cameras/BRView
	
	var start = camera.project_ray_origin(mousePos)
	var direction = camera.project_ray_normal(mousePos)
	var end = start + direction * 100 # 100 = Distance
	
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	params.collide_with_areas = true
	params.collide_with_bodies = true
	
	var targetRay = space.intersect_ray(params)
	if type == "Any":
		return targetRay
	elif type == "Die":
		if targetRay.has("collider"):
			if targetRay["collider"].get_parent().get("data") != null:
				return targetRay["collider"].get_parent()
	elif type == "Button":
		if targetRay.has("collider"):
			if targetRay["collider"].get_parent().get_parent() != null:
				return targetRay["collider"].get_parent().get_parent()
# ANIMATION

func slideAnimation(object, mode: String, direction: String, startPos: float, endPos: float, nbFrames: int, secUntilNext: float):
	for frame in range(nbFrames):
		if not object.visible: return
		var progression := float(frame + 1) / nbFrames
		var easedProgression := pow(progression, 2) if mode == "Accélération" else 1.0 - pow(1.0 - progression, 2) if mode == "Décélération" else pow(0, 0)
		if direction == "x": object.position.x = lerp(startPos, endPos, easedProgression)
		elif direction == "y": object.position.y = lerp(startPos, endPos, easedProgression)
		elif direction == "z": object.position.z = lerp(startPos, endPos, easedProgression)
		if secUntilNext != 0: await wait(secUntilNext)

func floatYAnimation(object, radius: float):
	var startY: float = object.position.y 
	await slideAnimation(object, "Accélération", "y", startY, startY + radius/2, 20, 0.04)
	await slideAnimation(object, "Décélération", "y", startY + radius/2, startY + radius, 20, 0.04)
	while object.visible:
		await slideAnimation(object, "Accélération", "y", startY + radius, startY, 40, 0.04)
		await slideAnimation(object, "Décélération", "y", startY, startY - radius, 40, 0.04)
		await slideAnimation(object, "Accélération", "y", startY - radius, startY, 40, 0.04)
		await slideAnimation(object, "Décélération", "y", startY, startY + radius, 40, 0.04)
	object.position.y = startY

func visibilityAnimation(object, mode: String, methode: String, duration: int):
	var material = null
	
	if methode == "Material":
		var mesh = object as MeshInstance3D
		if mesh:
			material = mesh.get_active_material(0)
			material = material.duplicate()
			mesh.set_surface_override_material(0, material)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	if mode == "Show": 
		if object == $Fear: $Fear.position.y = -27.5
		object.show()
	for i in range(duration):
		if methode == "Modulate": object.modulate.a = 1.0 - float(i) / duration if (mode == "Hide") else float(i) / duration if (mode == "Show") else object.modulate.a
		elif methode == "Material" and material != null: material.albedo_color.a = 1.0 - float(i) / duration if (mode == "Hide") else float(i) / duration if (mode == "Show") else material.albedo_color.a
		await get_tree().process_frame
	if mode == "Hide": object.hide()

func colorAnimation(lights: Array, color: Color, duration: float = 0.6):
	for light in lights:
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(light, "light_color", color, duration)

func valueAnimation(label: Label3D, startValue: int, endValue: int, duration: float = 0.5):
	var steps = abs(endValue - startValue) + 1
	var timeStep = duration / steps
	var direction = sign(endValue - startValue)
	
	var currentValue = startValue
	var lastTen = int(float(currentValue) / 10)
	var lastHundred = int(float(currentValue) / 100)
	
	var isDie: bool = label.name == "ScoreLabel"
	
	if label == $FearHealthBar/Health: $FearHealthBar/FearHealth.scale = Vector3($FearHealthBar/FearHealth.scale.x, 1, 1)
	
	for i in range(steps):
		if label == $GUI/ScoreDie1/Score1 and currentValue != 0:
			var currentTen = int(float(currentValue) / 10)
			var currentHundred = int(float(currentValue) / 100)
			
			if currentTen != lastTen:
				if $GUI/ScoreDie10.position.y == 32.5 and direction > 0: slideAnimation($GUI/ScoreDie10, "Décélération", "y", 32.5, 0, 30, 0.03)
				$GUI/ScoreDie10/Score10.text = str(currentTen % 10)
				lastTen = currentTen

			if currentHundred != lastHundred:
				if $GUI/ScoreDie100.position.y == 32.5 and direction > 0: slideAnimation($GUI/ScoreDie100, "Décélération", "y", 32.5, 0, 30, 0.03)
				$GUI/ScoreDie100/Score100.text = str(currentHundred)
				lastHundred = currentHundred
			
			if endValue < startValue:
				if currentValue == 10: slideAnimation($GUI/ScoreDie10, "Accélération", "y", 0, 32.5, 30, 0.03)
				if currentValue == 100: slideAnimation($GUI/ScoreDie100, "Accélération", "y", 0, 32.5, 30, 0.03)
		
		elif label == $FearHealthBar/Health:
			fearCurrentHealth = currentValue
			var ratio = float(fearCurrentHealth) / float(fearMaxHealth)
			$FearHealthBar/FearHealth.scale.x = ratio
			$FearHealthBar/FearHealth.position.x = 7 - ratio * 7
		
		label.text = str(currentValue % 10) if (label == $GUI/ScoreDie1/Score1) else "x" + str(currentValue) if (label == $GUI/MultDie/Mult) else str(currentValue) + "/" + str(fearMaxHealth) + " PV" if (label == $FearHealthBar/Health) else str(currentValue) + " Phobie restante.." if (label == $FearHealthBar/FearLeftNb and currentValue <= 1) else str(currentValue) + " Phobies restantes.." if (label == $FearHealthBar/FearLeftNb and currentValue > 1) else str(currentValue)
		if isDie: label.modulate = Color(1.0,1.0,0.0) if (label.get_parent().data.augment[0] == "Or" and label.get_parent().data.augment[1] >= int(label.text)) else Color(0.360,0.825,1) if (label.get_parent().data.augment[0] == "Cristal" and label.get_parent().data.augment[1] >= int(label.text)) else Color(1.0,1.0,1.0)
		currentValue += direction
			
		await wait(timeStep)

func shopAnimation():
	isShopping = not isShopping
	buttonInGame["Roll"].get_node("RollButton/Body/Collider").disabled = isShopping
	buttonInGame["Next"].get_node("NextButton/Body/Collider").disabled = not isShopping
	for frame in range(18):
			$World/Boards/Center.rotation_degrees.x += 10 if isShopping else -10
			$World/Boards/Bottom.rotation_degrees.x += -10 if isShopping else 10
			await wait(0.01)

# GAMEPLAY

func revealFear(): # Intro de la Peur
	
	fearMaxHealth = 6 if (fearNum == 0) else 10 if (fearNum == 1) else 16 if (fearNum == 2) else 24 if (fearNum == 3) else 34 if (fearNum == 4) else 46 if (fearNum == 5) else 60
	if allFears[fearNum]["Name"] == "Atychiphobie" and jokerCountdown != 1: fearMaxHealth = int(float(fearMaxHealth) * 1.5)
	$FearHealthBar/Health.text = str(fearCurrentHealth) + "/" + str(fearMaxHealth) + "PV"
	
	await wait(0.2)
	if $World/Boards/BottomLeft/Cellphone/PhoneScreen.visible: $World/Boards/BottomLeft/Cellphone/PhoneScreen.hide()
	CameraTransition.transition_camera3D($Cameras/BalatroView, $Cameras/BRView, 0.8) # Intro Camera
	
	if fearNum == 0:
		await wait(0.75)
		revealDice(diceHand,0,0.08) # Intro Dés en Main
	
	valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,0,playerGold,0.3)
	
	await visibilityAnimation($FearHealthBar,"Show","Material",10)
	await wait(0.6)
	
	valueAnimation($FearHealthBar/FearLeftNb,0 if (fearNum == 0) else (6+1)-fearNum,6-fearNum,0.4)
	valueAnimation($FearHealthBar/Health, 0, fearMaxHealth, 0.4) # Intro PV Peur
	fearCurrentHealth = fearMaxHealth
	$Fear.texture = allFears[fearNum]["Texture"]
	$Fear.modulate = Color(1.0,1.0,1.0) if (allFears[fearNum]["Name"] == "Nihilophobie") else allFears[fearNum]["Color"]
	$World/Boards/TopLeft/PostIt/FearName.text = allFears[fearNum]["Name"] # Ambiance Peur
	$World/Boards/TopLeft/PostIt/FearName.modulate = allFears[fearNum]["Color"]
	$World/Boards/TopLeft/PostIt/FearText.text = allFears[fearNum]["Text"]
	$FearHealthBar/FearHealth.mesh.material.albedo_color = allFears[fearNum]["Color"]
	colorAnimation([$World/Lights/DoorLight, $World/Lights/RoomLight, $World/Lights/GameLight, $World/Lights/FearLight, $World/Lights/DiceLight, $World/Lights/PassiveLight, $World/Lights/CashLight], allFears[fearNum]["Color"], 1.2)
	await visibilityAnimation($Fear,"Show","Modulate",5)
	await slideAnimation($Fear, "Décélération", "y", -50, 5.5, 15, 0.03) # Intro Peur
	
	floatYAnimation($Fear, 1)
	floatYAnimation($FearHealthBar, 0.3)
	
	while $FearHealthBar/Health.text != str(fearMaxHealth) + "/" + str(fearMaxHealth) + " PV": await wait(0.1)
	
	await wait(1.2)
	CameraTransition.transition_camera3D($Cameras/BRView, $Cameras/BalatroView, 0.8) # Outro Camera

func createShop(): # Génère le Shop
	shop["Blanks"].clear()  # Nettoyer, balayer, astiquer Kaz la toujou penpan
	shop["Morphs"].clear()  # Nettoyer, balayer, astiquer Kaz la toujou penpan
	var shopBlanks = {}		# Nettoyer, balayer, astiquer Kaz la toujou penpan
	var shopMorphs = {}		# Nettoyer, balayer, astiquer Kaz la toujou penpan

	shopBlanks = RNG(All["Encyclopedia"]["Blank"], "Dictionnary", 3) # Tire au Sort 3 Dés Vierges
	for blankData in shopBlanks:
		var sides := []
		for i in range(blankData["NbFace"]):
			sides.append(i + 1)
		createDie(blankData["Nom"],"Normale",sides,["Normales",0],blankData["Prix"],shop["Blanks"])
	spawnDice(shop["Blanks"])
	for dieData in shop["Blanks"]: diceInGame[dieData].ShowLabel("Price", str(dieData.price))
	
	shopMorphs = RNG(All["Encyclopedia"]["Morph"], "Dictionnary", 2) # Tire au Sort 2 Morphs de Dé
	for morphData in shopMorphs:
		var sides := []
		for i in range(morphData["NbFace"]):
			sides.append(i + 1)
		createDie("D6",morphData["Nom"],sides,["Normales",0],morphData["Prix"],shop["Morphs"])
	spawnDice(shop["Morphs"])
	for dieData in shop["Morphs"]: diceInGame[dieData].ShowLabel("Price", str(dieData.price))
	
	shop["Augment"] = RNG(All["Encyclopedia"]["Augment"], "Dictionnary", 1)[0] # Tire au Sort 1 Augment
	buttonInGame["Augment"] = All["Prefabs"]["Button"].instantiate()
	$World/Boards/Center/Shop.add_child(buttonInGame["Augment"])
	buttonInGame["Augment"].global_transform.origin = Vector3(3.55, -0.7, -2.8)
	buttonInGame["Augment"].InitializeButton(self, "AugmentButton")
	buttonInGame["Augment"].ShowLabel("Augment", shop["Augment"]["Nom"])
	
	#shop["Passive"] = RNG(All["Encyclopedia"]["Passive"], "Dictionnary", 1)[0] # Tire au Sort 1 Passif
	#createPassive("Passive",shop["Passif"])
	
	actualizeDicePrice()

func switchFear():
	pass

func rollDice(): # Lance le(s) Dé(s)
	buttonInGame["Roll"].Press("Roll")
	
	if dicePlayed == [] or (allFears[fearNum]["Name"] == "Agoraphobie" and len(dicePlayed) > 2 and jokerCountdown != 1): 
		buttonInGame["Roll"].ShowLabel("Roll","ROLL",Color(1.0,0.0,0.0))
		await wait(0.3)
		buttonInGame["Roll"].ShowLabel("Roll","ROLL",Color(1.0,1.0,1.0))
		return
	
	targetedDie = null
	
	rollNum += 1
	rolls.clear()
	rollsSorted.clear()
	score = 0
	mult = 1 if (allFears[fearNum]["Name"] != "Koinophobie" and jokerCountdown != 1) else 0
	comb = {}
	
	if $World/Boards/BottomLeft/Cellphone/PhoneScreen.visible: $World/Boards/BottomLeft/Cellphone/PhoneScreen.hide()
	CameraTransition.transition_camera3D($Cameras/BalatroView, $Cameras/BRView, 0.5)
	
	if allFears[fearNum]["Name"] == "Nihilophobie" and rollNum % 2 == 1 and jokerCountdown != 1:
		for die in dicePlayed:
			await wait(0.8)
			diceInGame[die].PlayAnimation("Targeted", null)
			await wait(0.05)
			playerGold += floor((die.price/3)*2) if (floor((die.price/3)*2) != 0) else 1
			valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.3)
			
			if toUntargetDice.has(die): toUntargetDice.erase(die)
			diceInGame[die].queue_free()
			diceInGame.erase(die)
			dicePlayed = []
		await wait(0.5)
	else:
		for die in dicePlayed: if die.morph == "R. Dechu" and dicePlayed.find(die) - 1 != -1 : viegoCrown = dicePlayed[dicePlayed.find(die) - 1]
		for die in dicePlayed: # Lancer Invisible
			diceInGame[die].hide()
			var RNGsides = die.sides.duplicate()
			if die.augment[0] == "Void" and die.morph != "Holy Gr.":for face in range(die.augment[1]): RNGsides.erase(RNGsides[0])
			if die.morph == "Holy Gr.": RNGsides = [10]
			if die.morph == "Ultrakill": 
				mult+=1
				$GUI/MultDie/Mult.text = "x" + str(mult)
				RNGsides[0] = 0
			RNGsides.shuffle()
			rolls[die] = viegoCrown if (die.morph == "R. Dechu" and viegoCrown != null) else RNGsides[0]
			if viegoCrown is DieData: viegoCrown = rolls[die]
		
		rollsSorted = rolls.keys() # Trie Invisible
		rollsSorted.sort_custom(func(a, b): return rolls[a] < rolls[b]) 
		
		for die in rollsSorted: moveDie(die, dicePlayed, diceSorted) # Déplace
		
		if rollsSorted.size() > 1: # Suite
			comb["Current"] = "Suite"
			for i in range(rollsSorted.size() - 1):
				if rolls[rollsSorted[i]] + 1 != rolls[rollsSorted[i + 1]]: comb.erase("Current")
			if comb.has("Current"): if comb["Current"] == "Suite": comb[rollsSorted.size() - 1] = "Suite"
		
		if rollsSorted.size() > 3: # Carré
			if comb.has("Current"): comb["Real"] = comb["Current"]
			comb["Current"] = "Carré"
			for i in range(rollsSorted.size() - 1):
				if rolls[rollsSorted[i]] != rolls[rollsSorted[i + 1]]: comb.erase("Current")
			if comb.has("Current"): if comb["Current"] == "Carré": comb[3] = "Carré"
			if comb.has("Real"):
				comb["Current"] = comb["Real"]
				comb.erase("Real")
		
		if rollsSorted.size() > 2: # Brelant
			for i in range(rollsSorted.size() - 2):
				if rolls[rollsSorted[i]] == rolls[rollsSorted[i + 1]] and rolls[rollsSorted[i + 1]] == rolls[rollsSorted[i + 2]]:
					if not comb.values().has("Brelan"): comb[i+2] = "Brelan"
					if not comb.has("Current"): comb["Current"] = "Brelan"
		
		if rollsSorted.size() > 1: # Paire ou Double Paire
			for i in range(rollsSorted.size() - 1):
				if rolls[rollsSorted[i]] == rolls[rollsSorted[i + 1]]:
					if not comb.values().has("Paire"): comb[i+1] = "Paire"
					elif i == 2 and not (comb.values().has("Brelan") or comb.values().has("Carré")): comb[3] = "Double Paire"
					if not comb.has("Current"): comb["Current"] = "Paire"
					elif comb["Current"] == "Paire" and i == 2 and not (comb.values().has("Brelan") or comb.values().has("Carré")): comb["Current"] = "Double Paire"
		
		await wait(0.4) # Intro Score & Mult
		slideAnimation($GUI/ScoreDie1, "Décélération", "y", 32.5, 0, 30, 0.03)
		slideAnimation($GUI/MultDie, "Décélération", "y", 32.5, 0, 30, 0.03)
		if allFears[fearNum]["Name"] == "Koinophobie" and jokerCountdown != 1: $GUI/MultDie/Mult.text = "x0"
		
		await wait(0.8) # Trie Affiché
		await revealDice(diceSorted,0.05,0.4)
		
		if mult != 1 or (allFears[fearNum]["Name"] == "Koinophobie" and jokerCountdown != 1): # Animation Mult
			await slideAnimation($GUI/MultDie, "Décélération", "x", 18.05, 19.55, 6, 0.012)
			await slideAnimation($GUI/MultDie, "Accélération", "x", 19.55, 18.05, 4, 0.008)
			valueAnimation($GUI/MultDie/Mult, mult, 0 if (allFears[fearNum]["Name"] == "Koinophobie" and mult == 0 and jokerCountdown != 1) else 1, 0.6)
			await valueAnimation($GUI/ScoreDie1/Score1,score,score*mult,0.8)
			score *= mult
		
		if score != 0:
			await wait(0.2) # Animation Score
			while ((score >= 10 and $GUI/ScoreDie10.position.y != 0) or (score >= 100 and $GUI/ScoreDie100.position.y != 0)): await wait(0.1)
			if $GUI/ScoreDie100.position.y == 0: slideAnimation($GUI/ScoreDie100, "Décélération", "x", -28.85, -30.35, 6, 0.012) 
			if $GUI/ScoreDie10.position.y == 0: slideAnimation($GUI/ScoreDie10, "Décélération", "x", -22.25, -23.75, 6, 0.012)
			await slideAnimation($GUI/ScoreDie1, "Décélération", "x", -15.75, -17.25, 6, 0.012)
			if $GUI/ScoreDie100.position.y == 0: slideAnimation($GUI/ScoreDie100, "Accélération", "x", -30.35, -28.85, 4, 0.008)
			if $GUI/ScoreDie10.position.y == 0: slideAnimation($GUI/ScoreDie10, "Accélération", "x", -23.75, -22.25, 4, 0.008)
			await slideAnimation($GUI/ScoreDie1, "Accélération", "x", -17.25, -15.75, 4, 0.008)
			valueAnimation($GUI/ScoreDie1/Score1, score, 0, 1)
		
		await valueAnimation($FearHealthBar/Health, fearCurrentHealth, fearCurrentHealth - score if (fearCurrentHealth - score >= 0) else 0, 0.4) # Animation Fear Health Bar
		
		await wait(0.3)
		while ($GUI/ScoreDie10.position.y != 32.5 or $GUI/ScoreDie100.position.y != 32.5): await wait(0.1)
		slideAnimation($GUI/ScoreDie1, "Accélération", "y", 0, 32.5, 30, 0.03) # Outro Score & Mult
		slideAnimation($GUI/MultDie, "Accélération", "y", 0, 32.5, 30, 0.03)
		
		await wait(1) 
		if fearCurrentHealth == 0: # Outro Fear Si Fear Morte
			$FearHealthBar/Health.text = ""
			visibilityAnimation($FearHealthBar,"Hide","Material",10)
			await visibilityAnimation($Fear,"Hide","Modulate",75)
			$World/Boards/TopLeft/PostIt/FearName.text = ""
			$World/Boards/TopLeft/PostIt/FearText.text = ""
			$FearHealthBar/FearHealth.mesh.material.albedo_color = Color(1.0,0.0,0.0)
			colorAnimation([$World/Lights/DoorLight, $World/Lights/RoomLight, $World/Lights/GameLight, $World/Lights/FearLight, $World/Lights/DiceLight, $World/Lights/PassiveLight, $World/Lights/CashLight], Color(0.5,0.5,0.5), 1)
			fearNum += 1
			
			await wait(0.2) 
		
		for die in diceSorted: # Outro Dé(s)
			diceInGame[die].PlayAnimation("Targeted", null)
			await wait(0.05)
			if toUntargetDice.has(die): toUntargetDice.erase(die)
			diceInGame[die].queue_free()
			diceInGame.erase(die)
			diceInventory.append(die)
		diceSorted = []
		
		await wait(0.4)  
		if fearCurrentHealth == 0:
			for die in diceHand: # Outro Dé(s) en Main Si Fear Morte
				diceInGame[die].PlayAnimation("Targeted", null)
				await wait(0.05)
				playerGold += floor((die.price/3)*2) if (floor((die.price/3)*2) != 0) else 1
				await valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.4)
				diceInGame[die].PlayAnimation("Untargeted", null)
				await wait(0.5)
			await spawnDice(diceInventory)
			var diceInventoryCopy = diceInventory.duplicate()
			for die in diceInventoryCopy:
				diceInGame[die].hide()
				moveDie(die, diceInventory, diceHand)
				diceInGame[die].position.y += 0.25
			await revealDice(diceInventory, 0, 0.08)
			diceInventory = []
		
	await wait(0.2)
	if fearCurrentHealth != 0:
		if allFears[fearNum]["Name"] == "Peniaphobie" and jokerCountdown != 1 :
			playerGold -= rollNum*2
			valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.3)
		CameraTransition.transition_camera3D($Cameras/BRView, $Cameras/BalatroView, 0.8)
	
		if diceHand == [] and fearCurrentHealth>0: gameOver()
	else:
		if fearNum != 7:
			rollNum = 0
			createShop()
			await shopAnimation()
			await wait(0.5)
			CameraTransition.transition_camera3D($Cameras/BRView, $Cameras/BalatroView, 0.8)
		else:
			GameOverLayer.fade("In",Color(1.0,1.0,1.0))

func gameOver():
	GameOverLayer.fade("In",allFears[fearNum]["Color"])
	while not GameOverLayer.restart: await wait(0.1)
	GameOverLayer.restart = false
	
	# INITIAILSATION
	
	for die in diceInGame.values(): die.queue_free()
	
	diceInGame = {} # Réinitialisation des Variables
	diceHand = []
	dicePlayed = []
	diceSorted = []
	diceInventory = []
	allFears = []
	playerGold = 3
	$World/Boards/BottomRight/PiggyBank/PlayerGold.text = "0"
	$FearHealthBar/FearLeftNb.text = "0 Phobie restante.."
	rollNum = 0
	fearNum = 0
	fearCurrentHealth = 0
	
	$FearHealthBar/Health.text = "" # Réinitialisation de la Peur
	visibilityAnimation($FearHealthBar,"Hide","Material",5)
	await visibilityAnimation($Fear,"Hide","Modulate",5)
	for object in [$World/Boards/TopLeft/PostIt/FearName, $World/Boards/TopLeft/PostIt/FearText, $FearHealthBar/FearHealth, $World/Lights/DoorLight, $World/Lights/RoomLight, $World/Lights/GameLight, $World/Lights/FearLight, $World/Lights/DiceLight, $World/Lights/PassiveLight, $World/Lights/CashLight]:
		if object == $World/Boards/TopLeft/PostIt/FearName or object == $World/Boards/TopLeft/PostIt/FearText: object.text = "" # Reinitialisation Objets de la Peur 
		elif object == $FearHealthBar/FearHealth:
			object.mesh.material.albedo_color = Color(1.0,0.0,0.0)
			object.position = Vector3(7.0,0.028,0.0)
			object.scale = Vector3.ZERO
		elif object != $World/Boards/TopLeft/PostIt/FearText: object.light_color = Color(0.5,0.5,0.5)
	
	for die in range(4): # Créé 4 Dés et les Fait Spawner
		createDie("D6","Normale",[1,2,3,4,5,6],["Normales",0],3,diceHand)
	spawnDice(diceHand)
	for die in diceHand: diceInGame[die].hide()
	
	for fear in RNG(All["Encyclopedia"]["Fear"], "Dictionnary", 6): allFears.append(fear)
	allFears.append({"Name":"Dicephobie","Text":"Peur des Dés,\nse tient devans vous\nla forme ultime de\nvos peurs\nVous sentez-vous\ncapable de l'affronter ?","Color":Color(0.5,0.5,0.5),"Texture":dicephobiePNG})
	
	# FIGHT
	
	GameOverLayer.fade("Out")
	revealFear()

func phoneInfo(object, type: String): # Affiche sur l'Écran du Tel les Info de l'(object) Sélectionné de type (type)
	$World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = ""
	$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoSprite.hide()
	$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoStatus.text = ""
	$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoMorph.text = ""
	$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoAugment.text = ""
	$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoPrice.text = ""
	$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoValue.text = ""
	if type == "Dé":
		$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoSprite.show()
		var dieStatus = "En Main" if (diceHand.has(object)) else "En Jeu" if (dicePlayed.has(object)) else "En Forge" if (diePlayedInShop.has(object)) else "En Vente" if (shop["Blanks"].has(object) or shop["Morphs"].has(object)) else ""
		if dieStatus == "En Main" or dieStatus == "En Jeu" or dieStatus == "En Forge":
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = "DÉ À " + str(len(object.sides)) + " FACES"
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoSprite.texture = d2PNG if (len(object.sides) == 2) else d4PNG if (len(object.sides) == 4) else d6PNG if (len(object.sides) == 6) else d10PNG if (len(object.sides) == 10) else d20PNG if (len(object.sides) == 20) else placeHolderPNG
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoStatus.text = "\n\n\n\n\n\nStatut : " + dieStatus
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoMorph.text = "\n\n\n\n\n\n\nForme : Normale" if (object.morph == "Normale") else "\n\n\n\n\n\n\nForme : " + object.morph
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoAugment.text = "\n\n\n\n\n\n\n\nFaces : Normales" if (object.augment[0] == "Normales") else "\n\n\n\n\n\n\n\nFaces : " + object.augment[0] + " x" + str(object.augment[1])
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoPrice.text = "\n\n\n\n\n\n\n\n\nPrix : " + str(object.price) + " Pièces"
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoValue.text = "\n\n\n\n\n\n\n\n\n\nValeur : " + str(floor((object.price/3)*2)) + " Pièces" if (floor((object.price/3)*2) != 0) else "\n\n\n\n\n\n\n\n\n\nValeur : 1 Pièce"
		elif shop["Blanks"].has(object):
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = "DÉ À " + str(len(object.sides)) + " FACES"
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoSprite.texture = d2PNG if (len(object.sides) == 2) else d4PNG if (len(object.sides) == 4) else d6PNG if (len(object.sides) == 6) else d10PNG if (len(object.sides) == 10) else d20PNG if (len(object.sides) == 20) else placeHolderPNG
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoStatus.text = "\n\n\n\n\n\nStatut : " + dieStatus
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoPrice.text = "\n\n\n\n\n\n\nPrix : " + str(object.price) + " Pièces"
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoValue.text = "\n\n\n\n\n\n\n\nValeur : " + str(floor((object.price/3)*2)) + " Pièces" if (floor((object.price/3)*2) != 0) else "\n\n\n\n\n\n\n\nValeur : 1 Pièce"
		elif shop["Morphs"].has(object):
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoSprite.hide()
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = "ROI DECHU" + "\n\nSur Dé à " + str(len(object.sides)) + " Faces" if (object.morph == "R. Dechu") else "HOLY GRENADE" + "\n\nSur Dé à " + str(len(object.sides)) + " Faces" if (object.morph == "Holy Gr.") else object.morph.to_upper() + "\n\nSur Dé à " + str(len(object.sides)) + " Faces"
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoStatus.text = "\n\n\nStatut : " + dieStatus
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoMorph.text = "\n\n\n\nDescription :\n" + All["Encyclopedia"]["Morph"][object.morph]["Text"]
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoPrice.text = "\n\n\n\n\n\n\n\n\nPrix : " + str(object.price) + " Pièces"
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/InfoValue.text = "\n\n\n\n\n\n\n\n\n\nValeur : " + str(floor((object.price/3)*2)) + " Pièces" if (floor((object.price/3)*2) != 0) else "\n\n\n\n\n\n\n\n\n\nValeur : 1 Pièce"
	elif type == "Bouton":
		var buttonName = object.name
		if buttonName == "RollButton": $World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = "LANCER LES DÉS\n\nCe bouton sert à\nLancer les Dés\nSélectionnés à\nsa Gauche"
		elif buttonName == "AugmentButton":
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = "AMÉLIORER\n\nCe bouton sert à\nAméliorer face\npar face le Dé\nSéléctionné\nCoût : " + str(shop["Augment"]["Prix"]) + ( " Pièce\n\n" if shop["Augment"]["Prix"] == 1 else " Pièces\n\n")
			$World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text += "Or : Deux Face\ndonne l'Argent\nde leur Score" if (shop["Augment"]["Nom"] == "OR") else "Cristal : La Face\ncompte Double" if (shop["Augment"]["Nom"] == "CRISTAL") else "Void : La Face\nne compte Pas"
		elif buttonName == "SellButton": $World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = "VENDRE\n\nCe bouton sert à\nVendre le Dé\nSéléctionné\n\nLe Prix de Vente\ncorrespond au\n2/3 du Prix du Dé"
		elif buttonName == "NextButton": $World/Boards/BottomLeft/Cellphone/PhoneScreen/Info.text = "POURSUIVRE\n\nCe bouton sert à\nFermer le Shop\n\nLa prochaine\nPeur apparaitra\n\nÊtes-vous Prêt ?"

# IN GAME

func _process(delta): # À chaque frame (delta)

	mousePos = get_viewport().get_mouse_position() # Met à Jour la Position de la Souris
	if $Cameras/BalatroView.is_current(): 
		if target("Die"): # Si un Dé est Ciblé
			targetedDie = target("Die").data
			if not $World/Boards/BottomLeft/Cellphone/PhoneScreen.visible:
				phoneInfo(targetedDie,"Dé")
				$World/Boards/BottomLeft/Cellphone/PhoneScreen.show()
			
			if not toUntargetDice.has(targetedDie): # Si ce Dé n'est pas sur la Liste des Dés à Décibler, le Cibler puis l'y Ajouter
				if diceInGame[targetedDie].PlayAnimation("Targeted", ["Untargeted"]): toUntargetDice.append(targetedDie)
		
		elif target("Button"): # Si un Boutton est Ciblé
			if not $World/Boards/BottomLeft/Cellphone/PhoneScreen.visible:
				phoneInfo(target("Button"),"Bouton")
				$World/Boards/BottomLeft/Cellphone/PhoneScreen.show()
		
		elif $World/Boards/BottomLeft/Cellphone/PhoneScreen.visible: $World/Boards/BottomLeft/Cellphone/PhoneScreen.hide()
		
		if not target("Die"): targetedDie = null
		
	for die in toUntargetDice: # Si un Dé de la Liste des Dés à Décibler n'est plus Ciblé, le Décibler et l'y Retirer
		if die != targetedDie: if diceInGame[die].PlayAnimation("Untargeted", ["Targeted"]): toUntargetDice.erase(die)
	
	# INPUTS
	
	if Input.is_action_just_pressed("Select"): # Si Click Gauche est Pressé, met en Jeu le Dé Ciblé
		if targetedDie != null: 
			if not isShopping:
				if diceHand.has(targetedDie) and len(dicePlayed) < 4: moveDie(targetedDie, diceHand, dicePlayed) # Si le Dé peut être Joué, le Joue et lui Informe qu'il est Joué
				elif dicePlayed.has(targetedDie) and len(diceHand) < 8: moveDie(targetedDie, dicePlayed, diceHand) # Si le Dé peut être Rangé, le Joue et lui Informe qu'il est Rangé
			else:
				if diceHand.has(targetedDie) and len(diePlayedInShop) < 1:
					moveDie(targetedDie, diceHand,diePlayedInShop)
					valueAnimation(buttonInGame["Sell"].get_node("SellButton/LabelPrice"), int(buttonInGame["Sell"].get_node("SellButton/LabelPrice").text), floor((diePlayedInShop[0].price/3)*2) if (floor((diePlayedInShop[0].price/3)*2) != 0) else 1, 0.3) # Affiche le Prix de Vente qui correspond au 2/3 du Prix du Dé (arrondi inferieur prcq mechant devs bouuhh)
				elif diePlayedInShop.has(targetedDie):
					moveDie(targetedDie, diePlayedInShop,diceHand)
					valueAnimation(buttonInGame["Sell"].get_node("SellButton/LabelPrice"), int(buttonInGame["Sell"].get_node("SellButton/LabelPrice").text), 0, 0.1)
				elif shop["Blanks"].has(targetedDie) and (len(diceHand) + len(diePlayedInShop)) < 8: if playerGold >= targetedDie.price:
					moveDie(targetedDie, shop["Blanks"], diceHand) # Si le Blank peut être Acheter, l'Achète et lui Informe qu'il est Rangé
					valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.3)
					actualizeDicePrice()
				if shop["Morphs"].has(targetedDie) : if playerGold >= targetedDie.price: 
					applyMorph(targetedDie)
					valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.3)
					actualizeDicePrice() 
		
		if target("Button") != null :
			if not isShopping:
				if buttonInGame["Roll"] == target("Button"): 
					if $Cameras/BalatroView.is_current(): 
						rollDice()
			else:
				if buttonInGame["Augment"] == target("Button"):
					if diePlayedInShop == [] or playerGold < shop["Augment"]["Prix"] or (diePlayedInShop[0].augment[0].to_upper() != shop["Augment"]["Nom"] and diePlayedInShop[0].augment[0] != "Normales") or ((diePlayedInShop[0].augment[1] >= (19 if (diePlayedInShop[0].morph == "R. Dechu") else len(diePlayedInShop[0].sides)-1)) and (shop["Augment"]["Nom"] == "OR" or shop["Augment"]["Nom"] == "VOID")) or ((diePlayedInShop[0].augment[1] >= (20 if (diePlayedInShop[0].morph == "R. Dechu") else len(diePlayedInShop[0].sides))) and shop["Augment"]["Nom"] == "CRISTAL"):
						buttonInGame["Augment"].ShowLabel("Augment",shop["Augment"]["Nom"],Color(0.5, 0.5, 0.5))
						await wait(0.3)
						buttonInGame["Augment"].ShowLabel("Augment",shop["Augment"]["Nom"],Color(1.0,1.0,1.0))
					else:
						buttonInGame["Augment"].ShowLabel("Augment",shop["Augment"]["Nom"],	Color(1.0, 1.0, 0.0) if shop["Augment"]["Nom"] == "OR" else Color(0.360, 0.825, 1.0) if shop["Augment"]["Nom"] == "CRISTAL" else Color(0.1, 0.1, 0.1))
						if diePlayedInShop[0].augment[0] == "Normales": diePlayedInShop[0].augment[0] = "Or" if (shop["Augment"]["Nom"] == "OR") else "Cristal" if (shop["Augment"]["Nom"] == "CRISTAL") else "Void"
						diePlayedInShop[0].augment[1] += 2 if diePlayedInShop[0].augment[0] == "Or" else 1
						playerGold -= shop["Augment"]["Prix"]
						valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.4)
						actualizeDicePrice()
						await wait(0.3)
						buttonInGame["Augment"].ShowLabel("Augment",shop["Augment"]["Nom"],Color(1.0,1.0,1.0))
				elif buttonInGame["Sell"] == target("Button"):
					if not diePlayedInShop == [] and not diceHand == []:
						buttonInGame["Sell"].Press("Sell")
						playerGold += floor((diePlayedInShop[0].price/3)*2) if (floor((diePlayedInShop[0].price/3)*2) != 0) else 1
						diceInGame[diePlayedInShop[0]].queue_free() # Supprime le Node
						diceInGame.erase(diePlayedInShop[0]) # Supprime la Data 
						diePlayedInShop = [] # Supprime le Fantôme du Dé (AAAH POURQUOI FAUT SUPPRIMER 3 TRUCS DIFFERENTS C CHIANT)
						valueAnimation(buttonInGame["Sell"].get_node("SellButton/LabelPrice"), int(buttonInGame["Sell"].get_node("SellButton/LabelPrice").text), 0, 0.1)
						valueAnimation($World/Boards/BottomRight/PiggyBank/PlayerGold,int($World/Boards/BottomRight/PiggyBank/PlayerGold.text),playerGold,0.4)
						actualizeDicePrice() 
				elif buttonInGame["Next"] == target("Button"): 
					if not diePlayedInShop == []:
						moveDie(diePlayedInShop[0],diePlayedInShop,diceHand)
						valueAnimation(buttonInGame["Sell"].get_node("SellButton/LabelPrice"), int(buttonInGame["Sell"].get_node("SellButton/LabelPrice").text), 0, 0.1)
					if round($World/Boards/Center.rotation_degrees.x) == 180: 
						buttonInGame["Next"].Press("Next")
						for dieData in shop["Blanks"]:				# Nettoyer,
							if diceInGame.has(dieData):
								diceInGame[dieData].queue_free()	# balayer,
								diceInGame.erase(dieData)
						for dieData in shop["Morphs"]:				# astiquer
							if diceInGame.has(dieData):
								diceInGame[dieData].queue_free()	# Casa
								diceInGame.erase(dieData)
						buttonInGame["Augment"].queue_free()		# toujours
						buttonInGame.erase("Augment")
						#for dieData in shop["Passive"]:				# pimpante
							#if diceInGame.has(dieData):
								#diceInGame[dieData].queue_free()
								#diceInGame.erase(dieData)
						await shopAnimation()
						revealFear()
	
	if Input.is_action_just_pressed("Confirm"): # Si Espace est Pressé, Lance les Dés Joués
		if $Cameras/BalatroView.is_current():
			if not isShopping: rollDice()
			else:
				if not diePlayedInShop == []:
					moveDie(diePlayedInShop[0],diePlayedInShop,diceHand)
					valueAnimation(buttonInGame["Sell"].get_node("SellButton/LabelPrice"), int(buttonInGame["Sell"].get_node("SellButton/LabelPrice").text), 0, 0.1)
				if round($World/Boards/Center.rotation_degrees.x) == 180: 
					buttonInGame["Next"].Press("Next")
					for dieData in shop["Blanks"]:				# Nettoyer,
						if diceInGame.has(dieData):
							diceInGame[dieData].queue_free()	# balayer,
							diceInGame.erase(dieData)
					for dieData in shop["Morphs"]:				# astiquer
						if diceInGame.has(dieData):
							diceInGame[dieData].queue_free()	# Casa
							diceInGame.erase(dieData)
					buttonInGame["Augment"].queue_free()		# toujours
					buttonInGame.erase("Augment")
					#for dieData in shop["Passive"]:				# pimpante
						#if diceInGame.has(dieData):
							#diceInGame[dieData].queue_free()
							#diceInGame.erase(dieData)
					await shopAnimation()
					revealFear()
	
	if Input.is_action_pressed("QuickRestart") and $Cameras/BalatroView.is_current() and not isShopping and not GameOverLayer.isDying:
		QRtime += delta
		if QRtime >= 1:
			gameOver()
			QRtime = -999
	elif QRtime != 0: QRtime = 0
	
	# ADMIN INPUTS
	
	#if $Cameras/BalatroView.is_current(): # Si la Caméra Balatro est Active et Si Flèche du Bas est Pressé, Transitionne de la Caméra Balatro à la Caméra BR en 0,4 s
		#if Input.is_action_just_pressed("SwitchTOBRView"):
			#CameraTransition.transition_camera3D($Cameras/BalatroView, $Cameras/BRView, 0.4)

	#elif $Cameras/BRView.is_current(): # Sinon si la Caméra BR est Active et Si Flèche du Haut est Pressé, Transitionne de la Caméra BR à la Caméra Balatro en 0,4 s
		#if Input.is_action_just_pressed("SwitchToBalatroView"):
			#CameraTransition.transition_camera3D($Cameras/BRView, $Cameras/BalatroView, 0.4)
	
	#if Input.is_action_just_pressed("ShowOrHideShop"): shopAnimation()

func _ready(): # Au lancement du jeu
	
	# INITIAILSATION
	
	for die in range(4): # Créé 4 Dés et les Fait Spawner
		createDie("D6","Normale",[1,2,3,4,5,6],["Normales",0],3,diceHand)
	spawnDice(diceHand)
	for die in diceHand: diceInGame[die].hide()
	
	buttonInGame["Roll"] = All["Prefabs"]["Button"].instantiate() # Créé les Boutons
	$World/Boards/Bottom.add_child(buttonInGame["Roll"])
	buttonInGame["Roll"].global_transform.origin = Vector3(4.75, -0.85, 7)
	buttonInGame["Roll"].InitializeButton(self, "RollButton")
	
	buttonInGame["Next"] = All["Prefabs"]["Button"].instantiate()
	$World/Boards/Bottom.add_child(buttonInGame["Next"])
	buttonInGame["Next"].global_transform.origin = Vector3(2.125, -1.25, 7)
	buttonInGame["Next"].rotation_degrees.x = 180
	buttonInGame["Next"].InitializeButton(self, "NextButton")
	
	buttonInGame["Sell"] = All["Prefabs"]["Button"].instantiate()
	$World/Boards/Center/Shop.add_child(buttonInGame["Sell"])
	buttonInGame["Sell"].global_transform.origin = Vector3(3.55, -0.65, -4)
	buttonInGame["Sell"].InitializeButton(self, "SellButton")
	
	for fear in RNG(All["Encyclopedia"]["Fear"], "Dictionnary", 6): allFears.append(fear)
	allFears.append({"Name":"Dicephobie","Text":"Peur des Dés,\nla forme ultime\nde vous peur","Color":Color(0.5,0.5,0.5),"Texture":dicephobiePNG})
	
	# FIGHT
	
	for slide in range(4):
		while not Input.is_action_just_pressed("Select"): await wait(0.01)
		await wait(0.05)
		GameOverLayer.nextSlide()
	GameOverLayer.fade("Out")
	revealFear()
