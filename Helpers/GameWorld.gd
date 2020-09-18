extends Spatial

var mesh = Mesh.new()
var color = Color(255, 0, 0)

const TERRAIN_TYPE_ROCKY = 1
const TERRAIN_TYPE_HILLY = 3
const TERRAIN_TYPE_IN_BETWEEN = 5
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
var chunk = preload("res://Helpers/Chunk.tscn")
var testRock = preload("res://World Objects/Minerals/TestRock.tscn")
var platinum = preload("res://World Objects/Minerals/Platinum.tscn")

var inInventory = false

func _ready():
	randomize()
	
	noise.seed = randi()
	noise.octaves = 1
	noise.persistence = 0.8
	noise.period = TERRAIN_TYPE_IN_BETWEEN
	
	$UILayer/NormalUI.show()
	$UILayer/InventoryUI.hide()

func getNoise(x, z):
	if(TERRAIN_RESOLUTION == 1):
		return noise.get_noise_2d(x, z)
	return noise.get_noise_2d(x, z) * (TERRAIN_RESOLUTION / 2)

func getVertices(x, z, offsetX, offsetZ):
	var vertices = PoolVector3Array()
	
	vertices.push_back(Vector3(x + offsetX, getNoise(x, z), z + offsetZ))
	vertices.push_back(Vector3(x + offsetX + TERRAIN_RESOLUTION, getNoise(x + TERRAIN_RESOLUTION, z), z + offsetZ))
	vertices.push_back(Vector3(x + offsetX, getNoise(x, z + TERRAIN_RESOLUTION), z + offsetZ + TERRAIN_RESOLUTION))
	
	vertices.push_back(Vector3(x + offsetX, getNoise(x, z + TERRAIN_RESOLUTION), z + offsetZ + TERRAIN_RESOLUTION))
	vertices.push_back(Vector3(x + offsetX +TERRAIN_RESOLUTION, getNoise(x + TERRAIN_RESOLUTION, z), z + offsetZ))
	vertices.push_back(Vector3(x + offsetX +TERRAIN_RESOLUTION, getNoise(x + TERRAIN_RESOLUTION, z + TERRAIN_RESOLUTION), z + offsetZ + TERRAIN_RESOLUTION))
	
	return vertices
	
func getUVs(x, z, offsetX, offsetZ):
	var UVs = PoolVector2Array()
	
	UVs.push_back(Vector2(x + offsetX, z + offsetZ))
	UVs.push_back(Vector2(x + offsetX + TERRAIN_RESOLUTION, z + offsetZ))
	UVs.push_back(Vector2(x + offsetX, z + offsetZ + TERRAIN_RESOLUTION))
	
	UVs.push_back(Vector2(x + offsetX, z + offsetZ + TERRAIN_RESOLUTION))
	UVs.push_back(Vector2(x + offsetX + TERRAIN_RESOLUTION, z + offsetZ))
	UVs.push_back(Vector2(x + offsetX + TERRAIN_RESOLUTION, z + offsetZ + TERRAIN_RESOLUTION))
	
	return UVs

func createChunk(chunkX, chunkZ):
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	
	var originX = chunkX * CHUNK_SIZE * TERRAIN_RESOLUTION
	var originZ = chunkZ * CHUNK_SIZE * TERRAIN_RESOLUTION
		
	for x in range(0, CHUNK_SIZE):
		for z in range(0, CHUNK_SIZE):
			vertices.append_array(getVertices(x + originX, z + originZ, -originX, -originZ))
			UVs.append_array(getUVs(x + originX, z + originZ, -originX, -originZ))

	var currentChunk = chunk.instance()
	currentChunk.init(originX, originZ, vertices, UVs)
	currentChunk.name = str(chunkX) + "," + str(chunkZ)
	$Chunks.add_child(currentChunk)

	if(randi() % 50 + 1 == 5):
		var rockX = randi()%CHUNK_SIZE + (chunkX * CHUNK_SIZE)
		var rockZ = randi()%CHUNK_SIZE + (chunkZ * CHUNK_SIZE)

		var rock = platinum.instance()
		rock.global_translate(Vector3(rockX, 0, rockZ))
		currentChunk.add_child(rock)
	
func _process(delta):
	if(inInventory):
		if(Input.is_action_just_pressed("inventory")):
			inInventory = false
			get_tree().paused = false
			$UILayer/InventoryUI.hide()
			$UILayer/NormalUI.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		var pos = $Player.get_global_transform().origin
		$UILayer/NormalUI/DebugHUD/PositionLabel.text = "XYZ: " + str(pos.x) + "," + str(pos.y) + "," + str(pos.z)
		$UILayer/NormalUI/DebugHUD/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
		
		var text = "O2: "
		text += str($Player.oxygen) + "%\n"
		text += "Temp: " + str($Player.suitTemp) + "C\n"
		if($Player.waterReclaimerHealth > 80):
			text += "Water Reclaimer OK\n"
		elif($Player.waterReclaimerHealth > 40):
			text += "Water Reclaimer DEG\n"
		elif($Player.waterReclaimerHealth > 5):
			text += "Water Reclaimer BAD\n"
			
		if($Player.oxygenReclaimerHealth > 80):
			text += "Oxygen Reclaimer OK\n"
		elif($Player.oxygenReclaimerHealth > 40):
			text += "Oxygen Reclaimer DEG\n"
		elif($Player.oxygenReclaimerHealth > 5):
			text += "Oxygen Reclaimer BAD\n"
		
		text += "Thirst: " + str($Player.thirst) + "%\n"
		text += "Hunger: " + str($Player.hunger) + "%\n"
		$UILayer/NormalUI/StatsHUD/Label.text = text
		
		$UILayer/NormalUI/HPRect/ColorRect.rect_size.x = $Player.hp * 2
		
		var loadedChunksNeeded = []
		var playerChunkPos = Vector2(floor(pos.x / ORIGINAL_CHUNK_SIZE), floor(pos.z / ORIGINAL_CHUNK_SIZE))
		for x in range(-((RENDER_DISTANCE - 1) / 2), (RENDER_DISTANCE - 1) / 2):
			for z in range(-((RENDER_DISTANCE - 1) / 2), (RENDER_DISTANCE - 1) / 2):
				loadedChunksNeeded.append(Vector2(playerChunkPos.x + x, playerChunkPos.y + z))
				
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
			var chunkPos = child.name.split(",")
			var chunkX = int(chunkPos[0])
			var chunkY = int(chunkPos[1].split("@")[0])
			chunkPos = Vector2(chunkX, chunkY)
			
			if not(chunkPos in loadedChunksNeeded):
				child.queue_free()
	
		for chunkPos in loadChunks:
			createChunk(chunkPos.x, chunkPos.y)
			
		if(Input.is_action_just_pressed("inventory")):
			inInventory = true
			get_tree().paused = true
			$UILayer/InventoryUI.show()
			$UILayer/NormalUI.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
