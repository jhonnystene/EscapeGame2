extends StaticBody

var durabilityLeft = 5

func do_attack():
	durabilityLeft -= 1
	
	if(durabilityLeft == 0):
		queue_free()
