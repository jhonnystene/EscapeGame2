extends Spatial

var mesh = Mesh.new()
var color = Color(255, 0, 0)

const TERRAIN_TYPE_ROCKY = 1
const TERRAIN_TYPE_HILLY = 3
const TERRAIN_TYPE_FLAT = 20

const TERRAIN_MULTIPLIER_NORMAL = 1
const TERRAIN_MULTIPLIER_BIGBOI = 2
const TERRAIN_MULTIPLIER_AMPLIFIED = 5

const TERRAIN_RESOLUTION_PS1_HAGRID = 4
const TERRAIN_RESOLUTION_COARSE = 2
const TERRAIN_RESOLUTION_FINE = 1
const TERRAIN_RESOLUTION = TERRAIN_RESOLUTION_FINE

const ORIGINAL_CHUNK_SIZE = 16
const CHUNK_SIZE = ORIGINAL_CHUNK_SIZE / TERRAIN_RESOLUTION
const RENDER_DISTANCE = 9 # Must be odd and at least 3
const NOISE_MULTIPLIER = TERRAIN_MULTIPLIER_NORMAL

var noise = OpenSimplexNoise.new()
var chunk = preload("res://Chunk.tscn")
var testRock = preload("res://TestRock.tscn")

func getNoise(x, z):
	if(TERRAIN_RESOLUTION == 1):
		return noise.get_noise_2d(x, z)
	return noise.get_noise_2d(x, z) * (TERRAIN_RESOLUTION / 2)

func getVertices(x, z):
	var vertices = PoolVector3Array()
	
	vertices.push_back(Vector3(x, getNoise(x, z), z))
	vertices.push_back(Vector3(x + TERRAIN_RESOLUTION, getNoise(x + TERRAIN_RESOLUTION, z), z))
	vertices.push_back(Vector3(x, getNoise(x, z + TERRAIN_RESOLUTION), z + TERRAIN_RESOLUTION))
	
	vertices.push_back(Vector3(x, getNoise(x, z + TERRAIN_RESOLUTION), z + TERRAIN_RESOLUTION))
	vertices.push_back(Vector3(x + TERRAIN_RESOLUTION, getNoise(x + TERRAIN_RESOLUTION, z), z))
	vertices.push_back(Vector3(x + TERRAIN_RESOLUTION, getNoise(x + TERRAIN_RESOLUTION, z + TERRAIN_RESOLUTION), z + TERRAIN_RESOLUTION))
	
	return vertices
	
func getUVs(x, z):
	var UVs = PoolVector2Array()
	
	UVs.push_back(Vector2(x, z))
	UVs.push_back(Vector2(x + TERRAIN_RESOLUTION, z))
	UVs.push_back(Vector2(x, z + TERRAIN_RESOLUTION))
	
	UVs.push_back(Vector2(x, z + TERRAIN_RESOLUTION))
	UVs.push_back(Vector2(x + TERRAIN_RESOLUTION, z))
	UVs.push_back(Vector2(x + TERRAIN_RESOLUTION, z + TERRAIN_RESOLUTION))
	
	return UVs

func createChunk(chunkX, chunkZ):
	#print("Creating new chunk...")
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	
	#print("Initializing vertices and UVs...")
	for technicalX in range(chunkX * CHUNK_SIZE * TERRAIN_RESOLUTION, ((chunkX * CHUNK_SIZE) + CHUNK_SIZE) * TERRAIN_RESOLUTION):
		for technicalZ in range(chunkZ * CHUNK_SIZE * TERRAIN_RESOLUTION, ((chunkZ * CHUNK_SIZE) + CHUNK_SIZE) * TERRAIN_RESOLUTION):
			var x = technicalX #* TERRAIN_RESOLUTION
			var z = technicalZ# * TERRAIN_RESOLUTION
			
			vertices.append_array(getVertices(x, z))
			UVs.append_array(getUVs(x, z))
			
	#print("Instancing...")
	var currentChunk = chunk.instance()
	currentChunk.init(vertices, UVs)
	currentChunk.name = str(chunkX) + "," + str(chunkZ)
	#print("Name set to " + str(chunkX) + "," + str(chunkZ) + ".")
	
	#print("Adding as child to Chunks object...")
	$Chunks.add_child(currentChunk)
	
	#print("Generating rocks...")
	if(randi()%10+1 == 5):
		var rockX = randi()%CHUNK_SIZE + (chunkX * CHUNK_SIZE)
		var rockZ = randi()%CHUNK_SIZE + (chunkZ * CHUNK_SIZE)
		
		var rock = testRock.instance()
		rock.global_translate(Vector3(rockX, 0, rockZ))
		currentChunk.add_child(rock)

func _ready():
	randomize()
	
	var grassMaterial = load("res://material.tres")
	
	noise.seed = randi()
	noise.octaves = 1
	noise.persistence = 0.8
	noise.period = TERRAIN_TYPE_HILLY
	
func _process(delta):
	var pos = $Player.get_global_transform().origin
	$UILayer/DebugHUD/PositionLabel.text = "XYZ: " + str(pos.x) + "," + str(pos.y) + "," + str(pos.z)
	$UILayer/DebugHUD/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
	
	var loadedChunksNeeded = []
	var playerChunkPos = Vector2(floor(pos.x / ORIGINAL_CHUNK_SIZE), floor(pos.z / ORIGINAL_CHUNK_SIZE))
	for x in range(-((RENDER_DISTANCE - 1) / 2), (RENDER_DISTANCE - 1) / 2):
		for z in range(-((RENDER_DISTANCE - 1) / 2), (RENDER_DISTANCE - 1) / 2):
			loadedChunksNeeded.append(Vector2(playerChunkPos.x + x, playerChunkPos.y + z))
	
	#print("Player is at " + str(pos) + " (Chunk " + str(playerChunkPos) + ")")
	#print("Player is at " + str(playerChunkPos) + " so I need " + str(loadedChunksNeeded))
	
	var keepChunks = []
	for child in $Chunks.get_children():
		for position in loadedChunksNeeded:
			var chunkString = str(position.x) + "," + str(position.y)
			if(chunkString in child.name):
				keepChunks.append(position)
	
	var loadChunks = []
	for position in loadedChunksNeeded:
		if not(position in keepChunks):
			loadChunks.append(position)

	for child in $Chunks.get_children():
		var trash = true
		var chunkPos = child.name.split(",")
		var chunkX = int(chunkPos[0])
		var chunkY = int(chunkPos[1].split("@")[0])
		chunkPos = Vector2(chunkX, chunkY)
		
		if(chunkPos == playerChunkPos):
			#print("Player in chunk! Not trashing!")
			trash = false
		
		if(chunkPos in loadedChunksNeeded):
			trash = false
			
		if(trash):
			print("Trashing " + str(chunkPos) + "!")
			if(chunkPos == playerChunkPos):
				print("ERROR! Trying to trash player's chunk!")
			child.queue_free()

	for chunkPos in loadChunks:
		print("Loading new chunk: " + str(chunkPos))
		createChunk(chunkPos.x, chunkPos.y)
