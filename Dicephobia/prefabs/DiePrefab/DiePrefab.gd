extends Node3D

@export var main: Node = null
@export var data: DieData = null
@export var index: int = -1

var animPlayed: Array[String] = [] # Animation(s) en Cour
var animFrame: Array[int] = [] # Frame Actuel de l'/des Animation(s) en Cour

func InitializeDie(mainPath,dieData,dieIndex): # Initialise les Infos du Dé
	main = mainPath
	data = dieData
	index = dieIndex
	if data.sides.size() == 2 : $D2.show()
	if data.sides.size() == 4 : $D4.show()
	if data.sides.size() == 6 : $D6.show()
	if data.sides.size() == 10 : $D10.show()
	if data.sides.size() == 20 : $D20.show()

func ShowLabel(type: String, text: String = ""): # Affiche le prix du Dé, Si nécessaire
	if type == "Price":
		$PriceLabel.text = text
		$PriceLabel.visible = (text != "")
	elif type == "Score":
		$ScoreLabel.text = text
		$ScoreLabel.visible = (text != "")

func OrderDie(diceList): # Range le Dé, Si nécessaire
	if not diceList.has(data): return
	if diceList.find(data) < index:
		if diceList == main.diceHand:
			if PlayAnimation("OrderDH",null): index -= 1
		elif diceList == main.dicePlayed:
			if PlayAnimation("OrderDP",null): index -= 1

func PlayAnimation(anim,animCancel): # Tente de Lancer l'Animation (anim), Si aucune (animCancel) n'est déjà en cour, puis renvoie l'Échec ou la Réussite
	if animPlayed.has(anim): return false
	if animCancel != null:
		for animC in animCancel:
			if animPlayed.has(animC): return false
	animPlayed.append(anim)
	animFrame.append(1)
	return true

func ShowResultFace(value: int): # A RAJOUTER IMPORTANT   nbFace : int ---> Si c est un dé a x faces, la table de rotation est differente
	var rotation_map := {}
	#if nbFace == 2: var rotation_map := {}
	#if nbFace == 4: var rotation_map := {}
	#if nbFace == 6:
	rotation_map = {
		1: Vector3(deg_to_rad(180), deg_to_rad(90), 0),   # Chaque face a sa propre rotation en f(x) de la position de base du prefab 
		2: Vector3(deg_to_rad(-90), 0, 0),                 
		3: Vector3(0, deg_to_rad(-90), deg_to_rad(90)),   
		4: Vector3(0, deg_to_rad(90), deg_to_rad(-90)),   
		5: Vector3(deg_to_rad(90), deg_to_rad(180),0 ),   
		6: Vector3(0, 0, 0)}
	
	#if nbFace == 10: var rotation_map := {}
	#if nbFace == 20: var rotation_map := {}
	if rotation_map.has(value):
		rotation = Vector3(0, 0, 0)
		rotation += rotation_map[value]
		$ScoreLabel.position = Vector3.ZERO # pour que label du score tourne pas, on le reset au centre du dé
		$ScoreLabel.global_position += Vector3(0,1.66,0) # et on lui rajoute la bone hauteur

func _process(_delta): # À chaque frame (delta)
	if main == null or data == null: return # Si le Dé a été Initialisé
	
	for animIndex in range(animPlayed.size() - 1, -1, -1): # Joue les Animations en Cour
		var anim = animPlayed[animIndex]
		var movement: Vector3 = Vector3.ZERO
		
		if anim == "OrderDH":
			movement.z += -0.4
		if anim == "OrderDP":
			movement.x += -0.4
		if anim == "Targeted":
			movement.y += 0.25
		elif anim == "Untargeted":
			movement.y += -0.25
		
		if movement != Vector3.ZERO:
			position += movement
			animFrame[animIndex] += 1
			if ((anim == "OrderDH" or anim == "OrderDP") and animFrame[animIndex] > 5) or ((anim == "Targeted" or anim == "Untargeted") and animFrame[animIndex] > 2):
				animPlayed.remove_at(animIndex)
				animFrame.remove_at(animIndex)
