extends Control

var id = "test_item"
var count = 0

var goalX = 0
var goalY = 0

func _ready():
	goalX = rect_position.x
	goalY = rect_position.y

func _process(delta):
	rect_position.x += (goalX - rect_position.x) / 2
	rect_position.y += (goalY - rect_position.y) / 2
	
	$Count.text = str(count)
	$Sprite.texture = GlobalData.itemIds[id]
