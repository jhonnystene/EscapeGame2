extends Node

const COLLISION_TYPE_CONVEX = 0
const COLLISION_TYPE_CONCAVE = 1

var world_color = "#e63900"
var worldSeed = 0
var chunkSize = 4
var collisionType = 0
var chunkCount = 100
var terrainMultiplier = 2
var testMineral = preload("res://GameWorld/Minerals/TestMineral.tscn")
var mineralIlmenite = preload("res://GameWorld/Minerals/Ilmenite.tscn")
var mineralSilicon = preload("res://GameWorld/Minerals/Silicon.tscn")

var foundation = preload("res://GameWorld/Placeable/Floor.tscn")

var itemIds = {}
var craftingRecipies = {}
var crafting_recipie = preload("res://UI/CraftingRecipie.tscn")

var inventory = []
var inventory_queue = []
var inventory_item = preload("res://UI/InventoryItem.tscn")
var inventory_item_selected = 0

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

func _ready():
	randomize()
	print("Initializing items...")
	itemIds["test_rock"] = load("res://Sprites/Items/TestRock.png")
	itemIds["test_item"] = load("res://Sprites/Items/TestItem.png")
	itemIds["mining_beam"] = load("res://Sprites/Items/LaserPointer.png")
	itemIds["ilmenite"] = load("res://Sprites/Items/Ilmenite.png")
	itemIds["silicon"] = load("res://Sprites/Items/Silicon.png")

	print("Initializing crafting...")
	craftingRecipies["test_item"] = {"test_rock": 2}
	craftingRecipies["test_rock"] = {"test_rock": 4}

func create_world_seed(newSeed):
	if not(newSeed):
		print("DEBUG: No world seed given!")
		worldSeed = randi()
	newSeed = str(newSeed).to_utf8()
	worldSeed = ""
	for character in newSeed:
		worldSeed += str(int(character))
	worldSeed = int(worldSeed)
