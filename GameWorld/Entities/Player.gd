extends KinematicBody2D

var MOVE_SPEED = 50
var GRAVITY = 5
var JUMP_SPEED = 100
var verticalVelocity = 0

func _process(delta):
	if(Input.is_action_pressed("attack")):
		$MiningRayCast.visible = true
		$MiningRayCast.cast_to = get_global_mouse_position()
		
		$MiningRayCast.force_raycast_update()
		if($MiningRayCast.is_colliding() and "Rock" in $MiningRayCast.get_collider().name):
			$MiningRayCast.get_collider().get_parent().mine(delta)
			$MiningRayCast/Line2D.points = [Vector2(0, 0), $MiningRayCast.get_collider().get_global_transform()[2] - global_transform[2]]
			$MiningRayCast/MeshInstance2D.global_transform[2] = $MiningRayCast.get_collider().get_global_transform()[2]
		else:
			$MiningRayCast/Line2D.points = [Vector2(0, 0), get_global_mouse_position() - global_transform[2]]
			$MiningRayCast/MeshInstance2D.global_transform[2] = $MiningRayCast.cast_to
			
		$MiningRayCast/MeshInstance2D.rotation_degrees += 5
	else:
		$MiningRayCast.visible = false

func _physics_process(delta):
	var moveX = -int(Input.is_action_pressed("move_left"))
	moveX += int(Input.is_action_pressed("move_right"))
	moveX *= MOVE_SPEED
	
	if(is_on_floor()):
		if(Input.is_action_pressed("jump")):
			verticalVelocity = -JUMP_SPEED
	else:
		verticalVelocity += GRAVITY
	
	# This works around a quirk in the Godot physics engine that makes it
	# damn near impossible to go up the slopes in the game.
	$RayCast2D.force_raycast_update()
	if($RayCast2D.is_colliding() and moveX > 0):
		verticalVelocity = -5
	
	move_and_slide(Vector2(moveX, verticalVelocity), Vector2(0, -1))
