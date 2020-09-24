extends ColorRect

var id = 0
var count = 1

const FLOOR_TEXTURE = preload("res://Textures/Items/floor.png")
const DEBUG_TEXTURE = preload("res://Textures/icon.png")
const PLATINUM_TEXTURE = preload("res://Textures/Items/platinum.png")

func _process(delta):
	if(id == Global.ITEM_AIR):
		queue_free()
		
	if(id == Global.ITEM_FLOOR):
		$Sprite.texture = FLOOR_TEXTURE

	if(id == Global.ITEM_PLATINUM):
		$Sprite.texture = PLATINUM_TEXTURE

	if(id == Global.ITEM_DEBUG):
		$Sprite.texture = DEBUG_TEXTURE
		
	$Label.text = str(count)
