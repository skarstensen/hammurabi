extends Node

class_name Game

@export_group("UI Controls")
@export var menuSystem:Control
@export var gameUI:Control

@export var messageBox:RichTextLabel

@export var populationLabel:Label
@export var grainLabel:Label
@export var acresLabel:Label

@export var controlsContainer:ControlPanel
@export var playButtonsContainer:PanelContainer

@export_group("Game Parameters")
@export var defaultReignLength:int = 10
@export var startingPopulation:int = 95
@export var startingAcres:int = 1000
@export var grainRequiredPerPerson:int = 20
@export var acresTendedPerPerson:int = 10
@export var bushelsRequiredPerAcre:int = 2

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
		controlsContainer.yearLabel.text = str(year)

var reignLength:int
var landPrice:int
var starved:int
var cameToCity:int
var diedFromPlague:int
var eatenByRats:int
var harvestedPerAcre:int

var acresPlantedThisYear:int
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
	grainFedToPeople = population * grainRequiredPerPerson
	
	processYear()


func displayLine(text:String):
	if (messageBox.text == ""):
		messageBox.text = "%s" % text
	else:
		messageBox.text = "%s\n%s" % [messageBox.text, text]
	
	# Minor grammatical cleanup
	if (messageBox.text.contains(" 1 bushels")):
		messageBox.text = messageBox.text.replace("1 bushels", "1 bushel")
	
	if (messageBox.text.contains(" 1 people")):
		messageBox.text = messageBox.text.replace("1 people", "1 person")


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
	
	displayLine("The city owns %s acres of land." % land)
	displayLine("We harvested %s bushels of grain per acre." % harvestedPerAcre)
	
	if (eatenByRats > 0):
		displayLine("Rats ate %s bushels." % eatenByRats)
		
	displayLine("We now have %s bushels in storage." % grain)
	
	displayLine("Land is trading at %s bushels per acre." % landPrice)
	
	controlsContainer.setBuySellMode()


func processPopulationChange():
	starved = max(0, population - (grainFedToPeople / grainRequiredPerPerson))
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


func adjustLandOwnership(quantity:int):
	land += quantity
	grain -= quantity * landPrice

	setFeedMode()


func skipLandTrade():
	displayLine("Very well.  We shall not trade for any land this year.")
	setFeedMode()


func setFeedMode():
	displayLine("How many bushels of grain do you wish to feed our people?")
	controlsContainer.setFeedMode()
	

func setPlantMode():
	displayLine("How many acres of land do you wish to plant with seed?")
	controlsContainer.setPlantMode()
	
	
# Signal Handlers ##############################################################
func _on_menu_system_start_game(reign):
	reignLength = reign
	startGame()


func _on_play_again_button_pressed():
	startGame()


func _on_quit_to_title_button_pressed():
	menuSystem.show()
	gameUI.hide()


func _on_buy_button_pressed():
	var acresToPurchase:int = controlsContainer.quantity.value
	var cost:int = acresToPurchase * landPrice
	
	if (acresToPurchase == 0):
		skipLandTrade()
	else:
		if (cost <= grain):
			displayLine("Very well.  We have purchased %s acres of land." % acresToPurchase)
			adjustLandOwnership(acresToPurchase)
		else:
			displayLine("Hammurabi, that much land would cost us %s bushels of grain.  We only have %s available." % [cost, grain])


func _on_sell_button_pressed():
	var acresToSell:int = controlsContainer.quantity.value
	
	if (acresToSell == 0):
		skipLandTrade()
	else:
		if (acresToSell > land):
			displayLine("Hammurabi, you cannot sell that much land!  We only have %s acres." % land)
		else:
			displayLine("Very well.  We have sold %s acres of land." % acresToSell)
			adjustLandOwnership(acresToSell)


func _on_plant_button_pressed():
	var acresToPlant:int = controlsContainer.quantity.value
	var peopleNeeded:int = acresToPlant / acresTendedPerPerson
	var grainNeeded:int = acresToPlant / bushelsRequiredPerAcre
	var canPlant:bool = true

	if (peopleNeeded > population):
		displayLine("Hammurabi, we only have %s people to tend the crops!" % population)
		canPlant = false
	
	if (grainNeeded > grain):
		displayLine("Hammurabi, we only have %s bushels of grain in storage!" % grain)
		canPlant = false
	
	if (acresToPlant > land):
		displayLine("Hammurabi, we only have %s acres of land!" % land)
		canPlant = false
		
	if (canPlant):
		grain -= grainNeeded
		acresPlantedThisYear = acresToPlant
		displayLine("Very well.  We will plant %s acres of crops." % acresToPlant)
		controlsContainer.setNextMode()
	
	
func _on_feed_button_pressed():
	var bushelsForFood:int = controlsContainer.quantity.value
	
	if (bushelsForFood <= grain):
		grainFedToPeople = bushelsForFood
		grain -= grainFedToPeople
		displayLine("Very well.  We shall allocate %s bushels of grain for food." % grainFedToPeople)
		controlsContainer.setPlantMode()
	else:
		displayLine("Hammurabi, we don't have that much grain.  There are only %s bushels in storage." % grain)


func _on_next_year_button_pressed():
	advanceYear()


func _on_skip_button_pressed():
	skipLandTrade()
