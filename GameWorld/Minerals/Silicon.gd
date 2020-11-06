extends Node2D

var miningTime = 6
var id = "silicon"

func mine(delta):
	miningTime -= delta
	if(miningTime < 0):
		GlobalData.inventory_add_item(id)
		queue_free()
