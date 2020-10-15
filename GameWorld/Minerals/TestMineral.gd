extends Node2D

var miningTime = 2
var id = "test_rock"

func mine(delta):
	miningTime -= delta
	if(miningTime < 0):
		GlobalData.add_inventory_item(id)
		queue_free()
