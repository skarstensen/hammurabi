extends Control

@export var aboutDialog:Control
@export var titleMenu:Control
@export var gameTitleVersionLabel:Label

func _ready():
	gameTitleVersionLabel.text = gameTitleVersionLabel.text % ProjectSettings.get_setting("application/config/version")

func _on_about_ok_button_pressed():
	aboutDialog.hide()
