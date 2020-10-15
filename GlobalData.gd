extends Node

const COLLISION_TYPE_CONVEX = 0
const COLLISION_TYPE_CONCAVE = 1

var worldSeed = 0
var chunkSize = 4
var collisionType = 0
var chunkCount = 100
var terrainMultiplier = 2
var testMineral = preload("res://GameWorld/Minerals/TestMineral.tscn")

var itemIds = {}
var craftingRecipies = {}
var crafting_recipie = preload("res://UI/CraftingRecipie.tscn")

var inventory = []
var inventory_queue = []
var inventory_item = preload("res://UI/InventoryItem.tscn")
var inventory_item_selected = 0

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

func _ready():
	randomize()
	print("Initializing items...")
	itemIds["test_rock"] = load("res://Sprites/Items/TestRock.png")
	itemIds["test_item"] = load("res://Sprites/Items/TestItem.png")

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
