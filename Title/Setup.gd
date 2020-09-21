extends Control

func _ready():
	$TerrainResolution/Slider.value = Global.terrainResolution
	$TerrainMultiplier/Slider.value = Global.terrainMultiplier
	$TerrainType/Slider.value = Global.terrainType
	$ChunkSize/Slider.value = Global.chunkSize
	$SubchunkCollisionSize/Slider.value = Global.subchunkCollisionSize
	$RenderDistance/Slider.value = Global.renderDistance
	
func _process(delta):
	$SubchunkCollisionSize/Slider.max_value = $ChunkSize/Slider.value
	
	Global.terrainResolution = $TerrainResolution/Slider.value
	Global.terrainMultiplier = $TerrainMultiplier/Slider.value
	Global.terrainType = $TerrainType/Slider.value
	Global.chunkSize = $TerrainType/Slider.value
	Global.subchunkCollisionSize = $TerrainType/Slider.value
	Global.renderDistance = $RenderDistance/Slider.value

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Helpers/GameWorld.tscn")
