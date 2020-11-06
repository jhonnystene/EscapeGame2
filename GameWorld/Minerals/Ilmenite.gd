extends Node2D

var miningTime = 4
var id = "ilmenite"

func mine(delta):
	miningTime -= delta
	if(miningTime < 0):
		GlobalData.inventory_add_item(id)
		queue_free()
