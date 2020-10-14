extends KinematicBody2D

var MOVE_SPEED = 20
var GRAVITY = 5
var JUMP_SPEED = 100
var verticalVelocity = 0

func _physics_process(delta):
	var moveX = -int(Input.is_action_pressed("move_left"))
	moveX += int(Input.is_action_pressed("move_right"))
	moveX *= MOVE_SPEED
	
	if(is_on_floor()):
		if(Input.is_action_pressed("jump")):
			verticalVelocity = -JUMP_SPEED
	else:
		verticalVelocity += GRAVITY
	
	$RayCast2D.force_raycast_update()
	if($RayCast2D.is_colliding() and moveX > 0):
		verticalVelocity = -5
	
	move_and_slide(Vector2(moveX, verticalVelocity), Vector2(0, -1))
