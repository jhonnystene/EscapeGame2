extends KinematicBody2D

var MOVE_SPEED = 50
var GRAVITY = 5
var JUMP_SPEED = 100
var verticalVelocity = 0

func _ready():
	GlobalData.inventory_add_item("mining_beam")

func _process(delta):
	if(GlobalData.inventory_get_selected_item() == "mining_beam"):
		if(Input.is_action_pressed("attack")):
			$MiningRayCast.visible = true
			var x = clamp(get_global_mouse_position()[0] - global_transform[2][0], -30, 30)
			var y = clamp(get_global_mouse_position()[1] - global_transform[2][1], -30, 30)
			$MiningRayCast.cast_to = Vector2(x, y)
			
			$MiningRayCast.force_raycast_update()
			if($MiningRayCast.is_colliding() and GlobalData.object_has_property($MiningRayCast.get_collider(), "mineral")):
				$MiningRayCast.get_collider().get_parent().mine(delta)
				$MiningRayCast/Line2D.points = [Vector2(0, 0), $MiningRayCast.get_collider().get_global_transform()[2] - global_transform[2]]
				$MiningRayCast/MeshInstance2D.global_transform[2] = $MiningRayCast.get_collider().get_global_transform()[2]
			else:
				$MiningRayCast/Line2D.points = [Vector2(0, 0), (global_transform[2] + Vector2(x, y)) - global_transform[2]]
				$MiningRayCast/MeshInstance2D.global_transform[2] = global_transform[2] + $MiningRayCast.cast_to
				
			$MiningRayCast/MeshInstance2D.rotation_degrees += 5
		else:
			$MiningRayCast.visible = false
	else:
		$MiningRayCast.visible = false
	
	if(GlobalData.inventory_get_selected_item() == "test_item"):
		if($PlacementHelper.get_child_count() == 0):
			var instance = GlobalData.foundation.instance()
			instance.get_children()[0].queue_free()
			
			$PlacementHelper.add_child(instance)
		
		var child = $PlacementHelper.get_children()[0]
		child.global_transform[2] = get_global_mouse_position()
		
		if(Input.is_action_just_pressed("attack")):
			child.queue_free()
			var instance = GlobalData.foundation.instance()
			instance.global_transform[2] = get_global_mouse_position()
			for worldChild in get_parent().get_children():
				if("WorldObjectContainer" in worldChild.name):
					worldChild.add_child(instance)
			GlobalData.inventory_remove_item("test_item", 1)
	else:
		for child in $PlacementHelper.get_children():
			child.queue_free()
		
func _physics_process(delta):
	var moveX
	if($UILayer/UI.crafting):
		moveX = 0
	else:
		moveX = -int(Input.is_action_pressed("move_left"))
		moveX += int(Input.is_action_pressed("move_right"))
		
	moveX *= MOVE_SPEED
	
	if(is_on_floor()):
		if not($UILayer/UI.crafting):
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
