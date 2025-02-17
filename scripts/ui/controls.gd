extends PanelContainer

class_name ControlPanel

@export var yearLabel:Label
@export var quantity:SpinBox
@export var buyButton:Button
@export var sellButton:Button
@export var skipButton:Button
@export var plantButton:Button
@export var feedButton:Button
@export var nextButton:Button

func hideAllButtons():
	buyButton.hide()
	sellButton.hide()
	skipButton.hide()
	plantButton.hide()
	feedButton.hide()
	nextButton.hide()
	
	quantity.value = 0


func setBuySellMode():
	hideAllButtons()
	quantity.show()
	quantity.suffix = "acres"
	buyButton.show()
	sellButton.show()
	skipButton.show()


func setPlantMode():
	hideAllButtons()
	quantity.suffix = "acres"
	plantButton.show()


func setFeedMode():
	hideAllButtons()
	quantity.suffix = "bushels"
	feedButton.show()


func setNextMode():
	hideAllButtons()
	quantity.hide()
	nextButton.show()
