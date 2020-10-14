extends Camera2D

func _process(delta):
	var moveX = -int(Input.is_action_pressed("move_left"))
	moveX += int(Input.is_action_pressed("move_right"))
	var moveY = -int(Input.is_action_pressed("move_forward"))
	moveY += int(Input.is_action_pressed("move_backward"))

	global_translate(Vector2(moveX, moveY))
