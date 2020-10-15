extends Control

func _on_CreateWorldButton_pressed():
	GlobalData.create_world_seed($SeedEntry.text)
	get_tree().change_scene("res://GameWorld/WorldContainer.tscn")
