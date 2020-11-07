extends Sprite

func finishPlace():
	for body in $BuildingSnapDetectors/LeftFloorSnap.get_overlapping_areas():
		print(body.name)
		if("FloorSnap" in body.name):
			global_transform[2].y = body.get_parent().get_parent().global_transform[2].y
			global_transform[2].x = body.get_parent().get_parent().global_transform[2].x + 8#?
			return
	
	for body in $BuildingSnapDetectors/RightFloorSnap.get_overlapping_areas():
		print(body.name)
		if("FloorSnap" in body.name):
			global_transform[2].y = body.get_parent().get_parent().global_transform[2].y
			global_transform[2].x = body.get_parent().get_parent().global_transform[2].x - 8#?
			return
