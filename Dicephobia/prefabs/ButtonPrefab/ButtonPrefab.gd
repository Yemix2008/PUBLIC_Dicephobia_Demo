extends Node3D

@export var main: Node = null

func InitializeButton(mainPath, buttonName): # Initialise les Infos du Dé
	main = mainPath
	name = buttonName
	
	hide()
	
	$RollButton.hide()
	$AugmentButton.hide()
	$SellButton.hide()
	$NextButton.hide()
	
	$AugmentButton/GoldMesh.hide()
	$AugmentButton/CristalMesh.hide()
	$AugmentButton/VoidMesh.hide()
	
	$RollButton/Body/Collider.disabled = true
	$AugmentButton/Body/Collider.disabled = true
	$SellButton/Body/Collider.disabled = true
	$NextButton/Body/Collider.disabled = true
	
	show()
	if name == "RollButton":
		$RollButton.show()
		$RollButton/Body/Collider.disabled = false
	elif name == "AugmentButton":
		$AugmentButton.show()
		$AugmentButton/Body/Collider.disabled = false
		if main.shop["Augment"]["Nom"] == "OR":
			$AugmentButton/GoldMesh.show()
			$AugmentButton/LabelPrice.text = "1"
		elif main.shop["Augment"]["Nom"] == "CRISTAL":
			$AugmentButton/CristalMesh.show()
			$AugmentButton/LabelPrice.text = "1"
		elif main.shop["Augment"]["Nom"] == "VOID":
			$AugmentButton/VoidMesh.show()
			$AugmentButton/LabelPrice.text = "2"
	elif name == "SellButton":
		$SellButton.show()
		$SellButton/Body/Collider.disabled = false
	elif name == "NextButton":
		$NextButton.show()

func ShowLabel(type: String, text: String = "", color: Color = Color(1, 1, 1)): # Affiche le prix du Dé, Si nécessaire
	if type == "Roll":
		$RollButton/LabelText.text = text
		$RollButton/LabelText.modulate = color
		$RollButton/LabelText.outline_modulate = color
		$RollButton/LabelText.visible = (text != "")
	elif type == "Augment":
		$AugmentButton/LabelText.text = text
		$AugmentButton/LabelText.modulate = color
		$AugmentButton/LabelText.outline_modulate = color
		$AugmentButton/LabelText.visible = (text != "")
	elif type == "Sell":
		$SellButton/LabelText.text = text
		$SellButton/LabelText.modulate = color
		$SellButton/LabelText.outline_modulate = color
		$SellButton/LabelText.visible = (text != "")
	elif type == "Next":
		$NextButton/LabelText.text = text
		$NextButton/LabelText.modulate = color
		$NextButton/LabelText.outline_modulate = color
		$NextButton/LabelText.visible = (text != "")

func Press(type: String):
	for frame in range(3): # Press
		if type == "Roll": $RollButton.position.y -= 0.04
		elif type == "Augment": $AugmentButton.position.y -= 0.04
		elif type == "Sell": $SellButton.position.y -= 0.04
		elif type == "Next": $NextButton.position.y -= 0.04
		await main.wait(0.04)
	if type == "Roll": $RollButton.position.y += 0.12 # Relax
	elif type == "Augment": $AugmentButton.position.y += 0.12
	elif type == "Sell": $SellButton.position.y += 0.12
	elif type == "Next": $NextButton.position.y += 0.12
