extends Node2D

var chunk = preload("res://GameWorld/Chunk.tscn")
var noise = OpenSimplexNoise.new()

func _ready():
	noise.seed = GlobalData.worldSeed
	noise.octaves = 1
	noise.persistence = 0.8
	noise.period = 20
	
	for x in range(0, GlobalData.chunkCount):
		var newChunk = chunk.instance()
		newChunk.generate(x, noise)
		add_child(newChunk)
