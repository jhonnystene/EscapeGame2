extends Node

var noise = OpenSimplexNoise.new()

func _ready():
	noise.seed = randi()
	noise.octaves = 3
	noise.persistence = 1
	noise.period = 1

func isMaterialAtChunk(chunkX, chunkZ):
	# TODO: Choose what material based on value
	if(noise.get_noise_2d(chunkX * 10, chunkZ * 10) > 0.9):
		return true
	return false
