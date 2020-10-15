extends Control

func _ready():
	GlobalData.add_inventory_item("test_item")

func _process(delta):
	for item in GlobalData.inventory_queue:
		$InventoryItems.add_child(item)
		GlobalData.inventory.append(item)
		GlobalData.inventory_queue.erase(item)
	
	for child in $InventoryItems.get_children():
		for item in GlobalData.inventory:
			if(item.id == child.id):
				child.count = item.count
				
				if(item.count):
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
