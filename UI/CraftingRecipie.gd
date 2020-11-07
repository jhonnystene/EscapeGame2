extends Control

var recipie = {"test_item": 0}
var resultCount = 0
var resultId = "test_item"

var goalX = 0
var goalY = 0

func _ready():
	goalX = rect_position.x
	goalY = rect_position.y

func _process(delta):
	rect_position.x += (goalX - rect_position.x) / 2
	rect_position.y += (goalY - rect_position.y) / 2
	
	if(len(recipie) == 1):
		$Needed2.visible = false
	else:
		$Needed2.visible = true
		$Needed2.texture = GlobalData.itemIds[recipie.keys()[1]]
		$Needed2/Count.text = str(recipie[recipie.keys()[1]])
	
	
	$Needed1.texture = GlobalData.itemIds[recipie.keys()[0]]
	$Needed1/Count.text = str(recipie[recipie.keys()[0]])
	
	$Result.texture = GlobalData.itemIds[resultId]
