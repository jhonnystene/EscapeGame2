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

var inventory = []
var inventory_queue = []
var inventory_item = preload("res://UI/InventoryItem.tscn")
var inventory_item_selected = 0

func add_inventory_item(itemId):
	for item in inventory:
		if(item.id == itemId):
			item.count += 1
			return
	var item = inventory_item.instance()
	item.id = itemId
	item.count = 1
	inventory_queue.append(item)

func _ready():
	randomize()
	print("Initializing items...")
	itemIds["test_rock"] = load("res://Sprites/Items/TestRock.png")
	itemIds["test_item"] = load("res://Sprites/Items/TestItem.png")

	print("Initializing crafting...")
	craftingRecipies["test_item"] = {"test_rock": 2}

func create_world_seed(newSeed):
	if not(newSeed):
		print("DEBUG: No world seed given!")
		worldSeed = randi()
	newSeed = str(newSeed).to_utf8()
	worldSeed = ""
	for character in newSeed:
		worldSeed += str(int(character))
	worldSeed = int(worldSeed)
