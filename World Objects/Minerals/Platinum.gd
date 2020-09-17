extends StaticBody

var durabilityLeft = 7

func do_attack():
	durabilityLeft -= 1
	
	if(durabilityLeft == 0):
		queue_free()
