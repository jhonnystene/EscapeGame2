extends Control

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://TitleScreen/NewGameMenu.tscn")

func _on_LoadGameButton_pressed():
	pass # Replace with function body.

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_ExitButton_pressed():
	get_tree().quit()
