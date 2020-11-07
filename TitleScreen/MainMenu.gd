extends Control

func _on_NewGameButton_pressed():
	GlobalData.inventory_add_item("mining_beam")
	get_tree().change_scene("res://TitleScreen/NewGameMenu.tscn")

func _on_LoadGameButton_pressed():
	GlobalData.serialisation_load()

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_ExitButton_pressed():
	get_tree().quit()
