extends Node

class_name Game

@export_group("UI Controls")
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

@export_group("Game Parameters")
@export var defaultReignLength:int = 10
@export var startingPopulation:int = 95
@export var startingAcres:int = 1000

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
var starved:int
var cameToCity:int
var diedFromPlague:int
var eatenByRats:int
var harvestedPerAcre:int

var acresPlantedThisYear:int
var landOwnedModifer:int
var grainFedToPeople:int

func startGame():
	menuSystem.hide()
	gameUI.show()
	
	controlsContainer.show()
	playButtonsContainer.hide()
	
	if (reignLength == defaultReignLength):
		displayLine("O wise Hammurabi, you have agreed to govern us for %s years." % reignLength)
	else:
		displayLine("O wise Hammurabi, you have agreed to govern us until the end of your days.")

	displayLine("May your reign be prosperous.")
	
	displayLine("")

	year = 1
	
	population = startingPopulation
	land = startingAcres
	acresPlantedThisYear = land
	
	processYear()


func _on_menu_system_start_game(reign):
	reignLength = reign
	startGame()


func displayLine(text:String):
	if (messageBox.text == ""):
		messageBox.text = "%s" % text
	else:
		messageBox.text = "%s\n%s" % [messageBox.text, text]
	
	# Minor grammatical cleanup
	if (messageBox.text.contains("1 bushels")):
		messageBox.text.replace("1 bushels", "1 bushel")
	
	if (messageBox.text.contains("1 people")):
		messageBox.text.replace("1 people", "1 person")


func processYear():
	processRats()
	processHarvest()
	processPopulationChange()
	calculateLandPrice()
	
	displayLine("Hammurabi, I beg to report to you...\n")
	
	displayLine("In year %s, %s people starved, and %s people came to the city." % [year, starved, cameToCity])
	
	if (diedFromPlague > 0):
		displayLine("A horrible plague struck!  Half the population died.")
	
	displayLine("The population is now %s." % population)
	
	displayLine("The city owns %s acres." % land)
	displayLine("We've harvested %s bushels per acre." % harvestedPerAcre)
	
	if (eatenByRats > 0):
		displayLine("Rats ate %s bushels." % eatenByRats)
		
	displayLine("We now have %s in storage." % grain)
	
	displayLine("Land is trading at %s bushels per acre." % landPrice)


func processPopulationChange():
	starved = max(0, population - (grainFedToPeople / 20))
	diedFromPlague = 0
	cameToCity = max(randi_range(1, 5) * (20 * land + grain) / population / 100, 1)
	
	population += cameToCity - starved
	
	if (randi_range(0, 100) <= 15):
		diedFromPlague = population / 2
		population -= diedFromPlague


func processHarvest():
	harvestedPerAcre = randi_range(1, 5)
	grain += acresPlantedThisYear * harvestedPerAcre


func processRats():
	eatenByRats = 0
	
	if (randi_range(0, 1) == 0):
		eatenByRats = grain / randi_range(1, 5)
	
	grain -= eatenByRats

func calculateLandPrice():
	landPrice = randi_range(17, 27)


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
