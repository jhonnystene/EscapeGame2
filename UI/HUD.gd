extends Control

var crafting = false
var currentCraftingRecipieShown = 0

func inventory_handle_queue():
	for item in GlobalData.inventory_queue:
		$InventoryItems.add_child(item)
		GlobalData.inventory.append(item)
		GlobalData.inventory_queue.erase(item)

func _process(delta):
	var craftingRecipies = GlobalData.crafting_get_available_recipies()
	if(Input.is_action_just_pressed("toggle_crafting")):
		if(crafting):
			crafting = false
		else:
			crafting = true
	
	if(len(craftingRecipies) == 0):
		currentCraftingRecipieShown = 0
		crafting = false
	
	if(crafting):
		if(Input.is_action_just_pressed("scroll_up")):
			currentCraftingRecipieShown -= 1
			if(currentCraftingRecipieShown < 0):
				currentCraftingRecipieShown = 0
		if(Input.is_action_just_pressed("scroll_down")):
			currentCraftingRecipieShown += 1
			if(currentCraftingRecipieShown > len(craftingRecipies) - 1):
				currentCraftingRecipieShown = len(craftingRecipies) - 1
				
		if(Input.is_action_just_pressed("jump")):
			GlobalData.crafting_craft(craftingRecipies[currentCraftingRecipieShown])
			if(currentCraftingRecipieShown > len(craftingRecipies) - 1):
				currentCraftingRecipieShown = len(craftingRecipies) - 1
			
	else:
		if(Input.is_action_just_pressed("scroll_up")):
			GlobalData.inventory_item_selected -= 1
			if(GlobalData.inventory_item_selected < 0):
				GlobalData.inventory_item_selected = 0
				
		if(Input.is_action_just_pressed("scroll_down")):
			GlobalData.inventory_item_selected += 1
			if(GlobalData.inventory_item_selected > len(GlobalData.inventory) - 1):
				GlobalData.inventory_item_selected = len(GlobalData.inventory) - 1
				
	inventory_handle_queue()
	for child in $InventoryItems.get_children():
		child.count = GlobalData.inventory_get_item_count(child.id)
		if(child.count):
			child.visible = true
		else:
			child.visible = false
	
	var vis_id = 0
	var childList = $InventoryItems.get_children()
	for child_id in range(0, len(childList)):
		if(childList[child_id].visible):
			childList[child_id].goalY = vis_id * 80
			childList[child_id].goalY -= GlobalData.inventory_item_selected * 80
			
			if(vis_id == GlobalData.inventory_item_selected):
				childList[child_id].goalX = 0
			else:
				childList[child_id].goalX = 64
				
			vis_id += 1
	
	for child in $CraftingRecipies.get_children():
		#print(child.resultId)
		if not(child.resultId in craftingRecipies):
			child.queue_free()
	
	for recipie in craftingRecipies:
			var exists = false
			for child in $CraftingRecipies.get_children():
				if(child.resultId == recipie):
					exists = true
			
			if not exists:
				var instance = GlobalData.crafting_recipie.instance()
				instance.resultId = recipie
				instance.resultCount = 1
				instance.recipie = GlobalData.craftingRecipies[recipie]
				$CraftingRecipies.add_child(instance)
		
	var children = $CraftingRecipies.get_children()
	for recipieId in range(0, len(craftingRecipies)):
		children[recipieId].goalX = 288 * recipieId
		children[recipieId].goalX -= 288 * currentCraftingRecipieShown
		if(recipieId == currentCraftingRecipieShown and crafting):
			children[recipieId].goalY = 0
		else:
			children[recipieId].goalY = 64
