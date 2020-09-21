extends Control

func _process(delta):
	if(Input.is_action_just_pressed("scroll_down")):
		Global.currentInventorySlotSelected += 1
	
	if(Input.is_action_just_pressed("scroll_up")):
		Global.currentInventorySlotSelected -= 1
		
	if(Global.currentInventorySlotSelected < 0):
		Global.currentInventorySlotSelected = 0
	elif(Global.currentInventorySlotSelected >= len(Global.playerInventory)):
		Global.currentInventorySlotSelected = len(Global.playerInventory) - 1
			
	rect_position.y = int((rect_position.y + (10 - (74 * Global.currentInventorySlotSelected))) / 2)
	
	for inventoryItemIndex in range(0, len(Global.playerInventory)):
		var goal = 0
		if not(inventoryItemIndex == Global.currentInventorySlotSelected):
			goal = 70
			#goal = int((Global.playerInventory[inventoryItemIndex].rect_position.x + 74) / 2)
		
		Global.playerInventory[inventoryItemIndex].rect_position.x = int((Global.playerInventory[inventoryItemIndex].rect_position.x + goal) / 2)
	
#	if($UILayer/NormalUI/Inventory.rect_position.y == int(10 - (74 * Global.currentInventorySlotSelected)) - 1):
#		for inventoryItemIndex in range(0, len(Global.playerInventory)):
#			if(inventoryItemIndex == Global.currentInventorySlotSelected):
#				Global.playerInventory[inventoryItemIndex].show()
#			else:
#				Global.playerInventory[inventoryItemIndex].hide()
#	else:
#		for inventoryItemIndex in range(0, len(Global.playerInventory)):
#			Global.playerInventory[inventoryItemIndex].show()
	
