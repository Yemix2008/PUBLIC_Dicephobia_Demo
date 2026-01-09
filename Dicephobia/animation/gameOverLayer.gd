extends CanvasLayer

var restart: bool = false
var isDying: bool = false
var slideNum: int = 0

func _ready():
	$BlackScreen.modulate = Color(0,0,0)
	
func fade(type: String, color: Color = Color(0,0,0)):
	if $IntroScreen.visible: $IntroScreen.hide()
	$Animation.play("fade" + type)
	isDying = (type == "In")
	if type == "In" and not color == Color(1,1,1):
		await get_tree().create_timer(2).timeout
		$GameOverLabel.modulate = color
		$RightLogoDeath.modulate = color
		$LeftLogoDeath.modulate = color
		$GameOverLabel.show()
		$RightLogoDeath.show()
		$LeftLogoDeath.show()
		await get_tree().create_timer(1).timeout
		$RestartButton.disabled = false
		$FightBack.show()
		await get_tree().create_timer(1).timeout
		if $FightBack.visible:
			$QuitButton.disabled = false
			$GiveUp.show()
	elif color == Color(1,1,1):
		await get_tree().create_timer(2).timeout
		$Congratulation.show()
		$RightLogoCongrats.show()
		$LeftLogoCongrats.show()

func nextSlide():
	if slideNum == 0:
		$IntroScreen/LeftLogo.hide()
		$IntroScreen/RightLogo.hide()
	slideNum += 1
	$IntroScreen/Lancer.visible = (slideNum == 1)
	$IntroScreen/Scorer.visible = (slideNum == 2)
	$IntroScreen/Acheter.visible = (slideNum == 3)

func restartPressed():
	$GameOverLabel.hide()
	$RightLogoDeath.hide()
	$LeftLogoDeath.hide()
	$RestartButton.disabled = true
	$FightBack.hide()
	$QuitButton.disabled = true
	$GiveUp.hide()
	await get_tree().create_timer(1).timeout
	restart = true

func quitPressed():
	get_tree().quit()
