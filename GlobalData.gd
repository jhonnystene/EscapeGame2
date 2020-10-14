extends Node

const COLLISION_TYPE_CONVEX = 0
const COLLISION_TYPE_CONCAVE = 1

var worldSeed = 0
var chunkSize = 4
var collisionType = 0
var chunkCount = 100
var terrainMultiplier = 2

func _ready():
	randomize()

func createWorldSeed(newSeed):
	if(newSeed == ""):
		worldSeed = randi()
	newSeed = str(newSeed).to_utf8()
	worldSeed = ""
	for character in newSeed:
		worldSeed += str(int(character))
	worldSeed = int(worldSeed)
