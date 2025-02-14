extends Node

class_name Game

@export var messageBox:RichTextLabel

@export var populationLabel:Label
@export var grainLabel:Label
@export var acresLabel:Label

@export var acresSpinbox:SpinBox

var population:int
var grain:int
var land:int

var reignLength:int

func startGame():
	pass


func _on_menu_system_start_game(reign):
	reignLength = reign
	startGame()
