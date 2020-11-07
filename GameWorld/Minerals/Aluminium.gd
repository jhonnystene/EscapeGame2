extends Node2D

var miningTime = 0.5
var id = "aluminium"

func mine(delta):
	miningTime -= delta
	if(miningTime < 0):
		GlobalData.inventory_add_item(id)
		queue_free()
