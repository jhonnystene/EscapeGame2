extends Node2D

var miningTime = 2
var id = "test_rock"

func mine(delta):
	miningTime -= delta
	if(miningTime < 0):
		GlobalData.inventory_add_item(id)
		queue_free()
