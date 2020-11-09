extends Node2D

var miningTime = 2
var id = "test_rock"
var color = Color(0, 0, 0)
var framesWithoutMine = 0

func _process(delta):
	for rect in $Rock/Display.get_children():
		rect.color = color
	framesWithoutMine += 1
	if(framesWithoutMine > 5):
		$Rock/AudioStreamPlayer2D.stop()

func mine(delta):
	framesWithoutMine = 0
	if(!$Rock/AudioStreamPlayer2D.playing):
		$Rock/AudioStreamPlayer2D.play()
	miningTime -= delta
	if(miningTime < 0):
		GlobalData.inventory_add_item(id)
		queue_free()

func serialise():
	var data = {}
	data["type"] = "mineral"
	data["x"] = global_transform[2][0]
	data["y"] = global_transform[2][1]
	data["id"] = id
	data["color"] = color.to_html()
	data["miningTime"] = miningTime
	return data

func fromSerialisedData(data):
	data = data
	global_transform[2][0] = data["x"]
	global_transform[2][1] = data["y"]
	id = data["id"]
	color = Color(data["color"])
	miningTime = int(data["miningTime"])
