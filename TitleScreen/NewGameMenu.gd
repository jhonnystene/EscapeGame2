extends Control

func _on_CreateWorldButton_pressed():
	GlobalData.createWorldSeed($SeedEntry.text)
	get_tree().change_scene("res://GameWorld/WorldContainer.tscn")
