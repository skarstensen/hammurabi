extends Node

class_name Game

const DEFAULT_REIGN_LENGTH:int = 10

@export var menuSystem:Control
@export var gameUI:Control

@export var messageBox:RichTextLabel

@export var populationLabel:Label
@export var grainLabel:Label
@export var acresLabel:Label
@export var yearCounterLabel:Label

@export var quantitySpinbox:SpinBox

@export var controlsContainer:PanelContainer
@export var playButtonsContainer:PanelContainer

var population:int:
	set(value):
		population = value
		populationLabel.text = str(population)
		
var grain:int:
	set(value):
		grain = value
		grainLabel.text = str(grain)
		
var land:int:
	set(value):
		land = value
		acresLabel.text = str(land)

var year:int:
	set(value):
		year = value
		yearCounterLabel.text = str(year)

var reignLength:int
var landPrice:int

func startGame():
	menuSystem.hide()
	gameUI.show()
	
	controlsContainer.show()
	playButtonsContainer.hide()
	
	if (reignLength == DEFAULT_REIGN_LENGTH):
		displayLine("O wise Hammurabi, you have agreed to govern us for %s years." % reignLength)
	else:
		displayLine("O wise Hammurabi, you have agreed to govern us until the end of your days.")

	displayLine("May your reign be prosperous.")
	
	displayLine("")

	year = 1
	
	population = 95
	grain = 3000
	land = 1000
	
	processYear()


func _on_menu_system_start_game(reign):
	reignLength = reign
	startGame()


func displayLine(text:String):
	if (messageBox.text == ""):
		messageBox.text = "%s" % text
	else:
		messageBox.text = "%s\n%s" % [messageBox.text, text]


func processYear():
	var statusReport:String = "In year %s, " % year
		
	displayLine("Hammurabi, I beg to report to you...")
	
	statusReport += processPopulationChange()
	
	displayLine(statusReport)
	
	displayLine(processHarvest())
	displayLine(calculateLandPrice())
	
	


func processPopulationChange() -> String:
	var populationChange:String = "%s people starved, and %s people came to the city."
	
	return populationChange


func processHarvest() -> String:
	var landOwnership:String = "The city owns %s acres."
	var grainHarvest:String = "We've harvested %s bushels per acre."
	var rats:String = "Rats ate %s bushels."
	var final:String = "We now have %s in storage."
	
	return "%s\n%s\n%s\n%s" % [landOwnership, grainHarvest, rats, final]


func calculateLandPrice() -> String:
	landPrice = randi_range(17, 27)
	
	return "Land is trading at %s bushels per acre." % landPrice


func advanceYear():
	messageBox.text = ""
	
	year = year + 1
	
	if (year <= reignLength):
		processYear()
	else:
		endReign()


func endReign():
	controlsContainer.hide()
	playButtonsContainer.show()


func _on_next_year_button_pressed():
	advanceYear()


func _on_play_again_button_pressed():
	startGame()


func _on_quit_to_title_button_pressed():
	menuSystem.show()
	gameUI.hide()
