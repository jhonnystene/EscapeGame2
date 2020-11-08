extends Node2D

var miningTime = 2
var id = "test_rock"
var color = Color(0, 0, 0)

func _process(delta):
	for rect in $Rock/Display.get_children():
		rect.color = color

func mine(delta):
	miningTime -= delta
	if(miningTime < 0):
		GlobalData.inventory_add_item(id)
		queue_free()
