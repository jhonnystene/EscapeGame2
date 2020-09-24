extends StaticBody

var durabilityLeft = 2

func do_attack():
	durabilityLeft -= 1
	
	if(durabilityLeft == 0):
		queue_free()
		return Global.ITEM_GOLD
	return Global.ITEM_AIR
