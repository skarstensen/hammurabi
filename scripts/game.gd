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

var yearlyStarvationPercentage:int
var totalDeaths:int

func startGame():
	menuSystem.hide()
	gameUI.show()
	
	controlsContainer.show()
	playButtonsContainer.hide()
	
	messageBox.text = ""
	
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
	
	yearlyStarvationPercentage = 0
	totalDeaths = 0
	
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
	
	if (messageBox.text.contains(" 1 acres")):
		messageBox.text = messageBox.text.replace("1 acres", "1 acre")


func processYear():
	processRats()
	processHarvest()
	processPopulationChange()
	calculateLandPrice()
	
	if (starved > population * 0.45):
		displayLine("Hammurabi!  You have starved %s people in one year!" % starved)
		displayLine("Due to this extreme mismanagement, the city elders have rallied the citizens against you.")
		displayLine("I suspect the mobs will be here to enforce your... \"dismissal\" shortly.")
		displayLine("If I were you, I'd slip out the back before they arrived.")
		updateHighScoreTable(year, 0)
		endReign()
	else:
		displayLine("Hammurabi, I beg to report to you...\n")
		
		displayLine("In year %s, %s people starved and %s people came to the city." % [year, starved, cameToCity])
		
		if (diedFromPlague > 0):
			displayLine("[color=red]A horrible plague struck!  Half the population died.[/color]")
		
		displayLine("The population is now %s." % population)
		
		displayLine("The city owns %s acres of land." % land)
		
		if (year > 1):
			if (acresPlantedThisYear == 0):
				displayLine("We did not plant any seeds nor harvest any grain.")
			else:
				displayLine("We planted %s acres and harvested %s bushels of grain per acre." % [acresPlantedThisYear, harvestedPerAcre])
		
		if (eatenByRats > 0):
			displayLine("[color=brown]Rats ate %s bushels.[/color]" % eatenByRats)
			
		displayLine("We have %s bushels in storage." % grain)
		
		displayLine("Land is trading at %s bushels per acre." % landPrice)
		
		controlsContainer.setBuySellMode()


func processPopulationChange():
	starved = max(0, population - (grainFedToPeople / grainRequiredPerPerson))
	diedFromPlague = 0
	cameToCity = max(randi_range(1, 5) * (20 * land + grain) / population / 100, 1)
	
	population += cameToCity - starved
	
	totalDeaths += starved
	yearlyStarvationPercentage = (year * yearlyStarvationPercentage + totalDeaths * 100 / population) / year
	
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
		showFinalEvaluation()
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
	

func showFinalEvaluation():
	var reignInYears:int = year - 1
	var startingAcresPerPerson:int = startingAcres / startingPopulation
	var endingAcresPerPerson:int = land / population
	var rank:int = 0
	
	displayLine("Hammurabi, your reign lasted a total of %s years." % reignInYears)
	displayLine("During that time, %s percent of the population starved per year, on average." % yearlyStarvationPercentage)
	displayLine("That is, a total of %s people died due to your mismanagement." % totalDeaths)
	displayLine("You started with %s acres of land per person and ended with %s." % [startingAcresPerPerson, endingAcresPerPerson])

	if (yearlyStarvationPercentage > 33 or endingAcresPerPerson < 7):
		displayLine("Unfortunately, due to your mismanagement the people have risen up against you and demanded your exile.  Could be worse, I guess.  Might I suggest slipping out the back?")
	elif(yearlyStarvationPercentage > 10 or endingAcresPerPerson < 9):
		rank = 1
		displayLine("Your heavy-handed rule reminds one of Emperor Nero, or perhaps Ivan the Terrible.  Yes, I know they haven't been born yet.")
	elif(yearlyStarvationPercentage > 3 or endingAcresPerPerson < 10):
		rank = 2
		displayLine("You could have done better, I suppose, but the good news is that only %s people are calling for your assassination." % randi_range(1, population * 0.80))
	else:
		displayLine("O wise Hammurabi, your wisdom exceeds that of Jefferson, Charlemagne, and Disraeli combined!  Yes, I know they haven't been born yet.")
		rank = 3
	
	updateHighScoreTable(reignInYears, rank)


func updateHighScoreTable(reign, rating):
	menuSystem.highScores.addEntry(reign, rating)


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
			displayLine("Hammurabi, that much land would cost us %s bushels of grain.  We only have %s bushels available." % [cost, grain])


func _on_sell_button_pressed():
	var acresToSell:int = controlsContainer.quantity.value
	
	if (acresToSell == 0):
		skipLandTrade()
	else:
		if (acresToSell > land):
			displayLine("Hammurabi, you cannot sell that much land!  We only have %s acres." % land)
		else:
			displayLine("Very well.  We have sold %s acres of land." % acresToSell)
			adjustLandOwnership(-acresToSell)


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
		setPlantMode()
	else:
		displayLine("Hammurabi, we don't have that much grain.  There are only %s bushels in storage." % grain)


func _on_next_year_button_pressed():
	advanceYear()


func _on_skip_button_pressed():
	skipLandTrade()
