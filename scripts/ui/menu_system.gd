extends Control

class_name MenuSystem

signal START_GAME(reign:int)

@export var aboutDialog:Control
@export var titleMenu:Control
@export var gameTitleVersionLabel:Label
@export var highScores:Control

func _ready():
	gameTitleVersionLabel.text = gameTitleVersionLabel.text % ProjectSettings.get_setting("application/config/version")

func _on_about_ok_button_pressed():
	aboutDialog.hide()


func _on_credits_button_pressed():
	aboutDialog.show()


func _on_ten_year_mode_button_pressed():
	START_GAME.emit(get_parent().defaultReignLength)


func _on_lifetime_mode_button_pressed():
	START_GAME.emit(randi_range(60, 80))


func _on_high_scores_button_pressed():
	pass # Replace with function body.
