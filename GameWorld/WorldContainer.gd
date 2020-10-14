extends Node2D

var chunk = preload("res://GameWorld/Chunk.tscn")
var noise = OpenSimplexNoise.new()

func reloadChunks():
	var playerChunk = $Player.get_global_transform()[2][0]
	playerChunk = int(playerChunk / GlobalData.chunkSize)
	
	var neededChunks = []
	var loadChunks = []
	
	for i in range(playerChunk - int(GlobalData.chunkCount / 2), playerChunk + int(GlobalData.chunkCount / 2)):
		neededChunks.append(str(i))
	
	for chunk in $Chunks.get_children():
		if not(chunk.name in neededChunks):
			chunk.queue_free()
		else:
			neededChunks.remove(neededChunks.find(chunk.name))
	
	for chunkId in neededChunks:
		chunkId = int(chunkId)
		var newChunk = chunk.instance()
		newChunk.generate(chunkId, noise)
		$Chunks.add_child(newChunk)

func _ready():
	noise.seed = GlobalData.worldSeed
	noise.octaves = 1
	noise.persistence = 0.8
	noise.period = 20

func _process(delta):
	reloadChunks()
