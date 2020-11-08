extends Node

const COLLISION_TYPE_CONVEX = 0
const COLLISION_TYPE_CONCAVE = 1

var world_color = "#e63900"
var worldSeed = 0
var chunkSize = 4
var collisionType = 0
var chunkCount = 100
var terrainMultiplier = 2

var loading = false

var minerals = {}
var mineralObject = preload("res://GameWorld/Entities/Mineral.tscn")
var generatedChunks = []

var foundation = preload("res://GameWorld/Placeable/Floor.tscn")

var itemIds = {}
var friendlyItemNames = {}
var craftingRecipies = {}
var crafting_recipie = preload("res://UI/CraftingRecipie.tscn")

var inventory = []
var inventory_queue = []
var inventory_item = preload("res://UI/InventoryItem.tscn")
var inventory_item_selected = 0

func serialisation_inventory_serialise():
	DebugConsole.echo("Serialisation: Serialising inventory...")
	var data = {}
	for item in inventory:
		data[item.id] = item.count
	DebugConsole.echo("Serialisation: Done serialising inventory.")
	return data

func serialisation_inventory_deserialise(data):
	DebugConsole.echo("Serialisation: Deserialising inventory...")
	for item in inventory:
		item.queue_free()
	
	for itemId in data:
		for i in range(0, data[itemId]):
			inventory_add_item(itemId)
	DebugConsole.echo("Serialisation: Done deserialising inventory.")

func serialisation_world_serialise():
	# We need these:
	# Player position (or at least player spawn position, if we decide to not do permadeath)
	# Building positions
	DebugConsole.echo("Serialisation: Serialising world data...")
	var data = {}
	data["worldSeed"] = worldSeed
	data["chunkSize"] = chunkSize
	data["collisionType"] = collisionType
	data["chunkCount"] = chunkCount
	data["terrainMultiplier"] = terrainMultiplier
	data["generatedChunks"] = generatedChunks
	DebugConsole.echo("Serialisation: Done serialising world data.")
	return data

func serialisation_world_deserialise(data):
	DebugConsole.echo("Serialisation: Deserialising world data...")
	worldSeed = data["worldSeed"]
	chunkSize = data["chunkSize"]
	collisionType = data["collisionType"]
	chunkCount = data["chunkCount"]
	terrainMultiplier = data["terrainMultiplier"]
	generatedChunks = data["generatedChunks"]
	DebugConsole.echo("Serialisation: Done deserialising world data.")
	
func serialisation_objects_serialise():
	DebugConsole.echo("Serialisation: Serialising objects...")
	var data = []
	for child in get_tree().get_root().get_children():
		if("WorldContainer" in child.name):
			for subchild in child.get_children():
				if("WorldObjectContainer" in subchild.name):
					for object in subchild.get_children():
						if("Serialisable" in object.name):
							data.append(object.serialise())
	DebugConsole.echo("Serialisation: Finished serialising objects.")
	return data

func serialisation_objects_deserialise(data):
	DebugConsole.echo("Serialisation: Deserialising objects...")
	for child in get_tree().get_root().get_children():
		if("WorldContainer" in child.name):
			for subchild in child.get_children():
				if("WorldObjectContainer" in subchild.name):
					for object in data:
						if(object["type"] == "mineral"):
							var instance = mineralObject.instance()
							instance.fromSerialisedData(object)
							subchild.add_child(instance)
						else:
							DebugConsole.echo("Serialisation: Unknown type: " + object["type"])
					return
	DebugConsole.echo("Serialisation: Finished deserialising objects.")
	
func serialisation_save():
	DebugConsole.echo("Serialisation: Saving game...")
	var data = serialisation_serialise()
	var file = File.new()
	file.open("user://save.json", File.WRITE)
	file.store_line(to_json(data))
	file.close()
	DebugConsole.echo("Serialisation: Done saving.")

func serialisation_load():
	DebugConsole.echo("Serialisation: Loading game...")
	var file = File.new()
	if not(file.file_exists("user://save.json")):
		DebugConsole.echo("Serialisation: Error! save.json not found")
		return
	file.open("user://save.json", File.READ)
	var data = parse_json(file.get_line())
	file.close()
	serialisation_deserialise(data)
	DebugConsole.echo("Serialisation: Done loading.")

func serialisation_serialise():
	var data = {}
	data["inventory"] = serialisation_inventory_serialise()
	data["world"] = serialisation_world_serialise()
	data["objects"] = serialisation_objects_serialise()
	return data

func serialisation_deserialise(data):
	serialisation_inventory_deserialise(data["inventory"])
	serialisation_world_deserialise(data["world"])
	serialisation_objects_deserialise(data["objects"])
	return

func inventory_is_mining_tool(id):
	if("mining_beam" in id):
		return true
	return false
	
func inventory_get_miner_speed(id, delta):
	if(id == "advanced_mining_beam"):
		return delta * 2
	
	return delta

func inventory_get_selected_item():
	if(len(inventory)):
		var trueInventoryPosition = 0
		for itemId in range(0, len(inventory)):
			if(trueInventoryPosition > len(inventory) - 1):
				return "mining_beam"
			if(inventory[itemId].count):
				if(trueInventoryPosition == inventory_item_selected):
					return inventory[itemId].id
				trueInventoryPosition += 1
	return "mining_beam"

func inventory_add_item(itemId):
	for item in inventory:
		if(item.id == itemId):
			item.count += 1
			return
	var item = inventory_item.instance()
	item.id = itemId
	item.count = 1
	inventory_queue.append(item)

func inventory_get_item_count(id):
	var count = 0
	for item in inventory:
		if(item.id == id):
			count = item.count
			return count
	return count
	
func inventory_remove_item(id, count):
	for item in inventory:
		if(item.id == id):
			item.count -= count
			if(item.count < 0):
				item.count = 0

func crafting_can_craft(id):
	var recipie = craftingRecipies[id]
	for neededItem in recipie:
		if(inventory_get_item_count(neededItem) < recipie[neededItem]):
			return false
	return true

func crafting_craft(id):
	if(crafting_can_craft(id)):
		inventory_add_item(id)
		if(inventory_is_mining_tool(id)):
			inventory.push_front(inventory.pop_back())
		for prereq in craftingRecipies[id]:
			inventory_remove_item(prereq, craftingRecipies[id][prereq])

func crafting_get_available_recipies():
	var availableRecipies = []
	for recipie in craftingRecipies:
		if(crafting_can_craft(recipie)):
			availableRecipies.append(recipie)
	return availableRecipies
	
func object_get_properties(object):
	var properties = []
	if("Mineral" in object.name or "Rock" in object.name):
		properties.append("mineral")
	
	if("Container" in object.name): 
		properties.append("object_container")
	
	if("Building" in object.name):
		properties.append("building_material")
		
	return properties

func object_has_property(object, property):
	if(property in object_get_properties(object)):
		return true
	return false

func file_load_as_json(path):
	var file = File.new()
	var data = ""
	file.open(path, File.READ)
	while(file.get_position() < file.get_len()):
		data += file.get_line()
	file.close()
	data = parse_json(data)
	return data

func game_initialise():
	DebugConsole.echo("GameData-Load: Loading item information...")
	var itemData = file_load_as_json("res://GameData/items.json")
	for item in itemData:
		itemIds[item] = load(itemData[item]["image"])
		friendlyItemNames[item] = itemData[item]["friendly"]
	
	DebugConsole.echo("GameData-Load: Loading crafting recipies...")
	var craftingData = file_load_as_json("res://GameData/crafting.json")
	for result in craftingData:
		craftingRecipies[result] = craftingData[result]
		
	DebugConsole.echo("GameData-Load: Loading mineral information...")
	var mineralData = file_load_as_json("res://GameData/minerals.json")
	for mineral in mineralData:
		minerals[mineral] = mineralData[mineral]

func world_get_mineral(chunkX):
	if(chunkX in generatedChunks):
		return false
	generatedChunks.append(chunkX)
	var instance = mineralObject.instance()
	for mineral in minerals:
		if(int(rand_range(0, minerals[mineral]["rarity"])) == 1):
			instance.id = mineral
			instance.miningTime = minerals[mineral]["miningTime"]
			instance.color = Color(minerals[mineral]["color"])
			return instance
	return false

func _ready():
	randomize()

func create_world_seed(newSeed):
	if not(newSeed):
		DebugConsole.echo("DEBUG: No world seed given!")
		worldSeed = randi()
	newSeed = str(newSeed).to_utf8()
	worldSeed = ""
	for character in newSeed:
		worldSeed += str(int(character))
	worldSeed = int(worldSeed)
