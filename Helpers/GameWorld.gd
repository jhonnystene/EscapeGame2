extends Spatial

var mesh = Mesh.new()
var color = Color(255, 0, 0)

var CHUNK_SIZE = 0

var noise = OpenSimplexNoise.new()
var biomeNoise = OpenSimplexNoise.new()

var chunk = preload("res://Helpers/Chunk.tscn")
var testRock = preload("res://World Objects/Minerals/TestRock.tscn")
var platinum = preload("res://World Objects/Minerals/Platinum.tscn")

var inInventory = false
var item = preload("res://Helpers/InventoryItem.tscn")

func _ready():
	CHUNK_SIZE = Global.chunkSize / Global.terrainResolution
	randomize()
	
	noise.seed = randi()
	noise.octaves = 1
	noise.persistence = 0.8
	noise.period = Global.TERRAIN_TYPE_IN_BETWEEN
	
	biomeNoise.seed = randi()
	noise.octaves = 1
	noise.persistence = 0.8
	noise.period = 3
	
	$UILayer/NormalUI.show()
	$UILayer/InventoryUI.hide()

func addInventoryItem(id):
	for item in Global.playerInventory:
		if(item.id == id):
			item.count += 1
			return
	
	var instance = item.instance()
	instance.id = id
	instance.rect_position.y = 74 * len(Global.playerInventory)
	Global.playerInventory.append(instance)
	$UILayer/NormalUI/Inventory.add_child(instance)

func getNoise(x, z):
	var noiseValue = noise.get_noise_2d(x, z)
	var biomeNoiseValue = abs(biomeNoise.get_noise_2d(floor(x / 10), floor(z / 10)) * 10)
	
	if(biomeNoiseValue > 0.8):
		noiseValue *= 1.5
	else:
		noiseValue *= 1
	
	if(Global.terrainResolution == 1):
		return noiseValue
	return noiseValue * (Global.terrainResolution / 2)

func getVertices(x, z, offsetX, offsetZ):
	var vertices = PoolVector3Array()
	
	vertices.push_back(Vector3(x + offsetX, getNoise(x, z), z + offsetZ))
	vertices.push_back(Vector3(x + offsetX + Global.terrainResolution, getNoise(x + Global.terrainResolution, z), z + offsetZ))
	vertices.push_back(Vector3(x + offsetX, getNoise(x, z + Global.terrainResolution), z + offsetZ + Global.terrainResolution))
	
	vertices.push_back(Vector3(x + offsetX, getNoise(x, z + Global.terrainResolution), z + offsetZ + Global.terrainResolution))
	vertices.push_back(Vector3(x + offsetX +Global.terrainResolution, getNoise(x + Global.terrainResolution, z), z + offsetZ))
	vertices.push_back(Vector3(x + offsetX +Global.terrainResolution, getNoise(x + Global.terrainResolution, z + Global.terrainResolution), z + offsetZ + Global.terrainResolution))
	
	return vertices
	
func getUVs(x, z, offsetX, offsetZ):
	var UVs = PoolVector2Array()
	
	UVs.push_back(Vector2(x + offsetX, z + offsetZ))
	UVs.push_back(Vector2(x + offsetX + Global.terrainResolution, z + offsetZ))
	UVs.push_back(Vector2(x + offsetX, z + offsetZ + Global.terrainResolution))
	
	UVs.push_back(Vector2(x + offsetX, z + offsetZ + Global.terrainResolution))
	UVs.push_back(Vector2(x + offsetX + Global.terrainResolution, z + offsetZ))
	UVs.push_back(Vector2(x + offsetX + Global.terrainResolution, z + offsetZ + Global.terrainResolution))
	
	return UVs

func createChunk(chunkX, chunkZ):
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	
	var originX = chunkX * CHUNK_SIZE * Global.terrainResolution
	var originZ = chunkZ * CHUNK_SIZE * Global.terrainResolution
		
	for x in range(0, CHUNK_SIZE):
		for z in range(0, CHUNK_SIZE):
			var verts = getVertices(x + originX, z + originZ, -originX, -originZ)
			vertices.append_array(verts)
			UVs.append_array(getUVs(x + originX, z + originZ, -originX, -originZ))
	
	var currentChunk = chunk.instance()
	currentChunk.init(originX, originZ, vertices, UVs)
	currentChunk.name = str(chunkX) + "," + str(chunkZ)
	$Chunks.add_child(currentChunk)

	if(randi() % 50 + 1 == 5):
		var rockX = int(randi())%int(CHUNK_SIZE) + (chunkX * CHUNK_SIZE)
		var rockZ = int(randi())%int(CHUNK_SIZE) + (chunkZ * CHUNK_SIZE)

		var rock = platinum.instance()
		rock.global_translate(Vector3(rockX, 0, rockZ))
		currentChunk.add_child(rock)
	
func _process(delta):
	if(Input.is_action_just_pressed("drop_to_menu")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://Title/Setup.tscn")
	
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
		var playerChunkPos = Vector2(floor(pos.x / Global.chunkSize), floor(pos.z / Global.chunkSize))
		for x in range(-((Global.renderDistance - 1) / 2), (Global.renderDistance - 1) / 2):
			for z in range(-((Global.renderDistance - 1) / 2), (Global.renderDistance - 1) / 2):
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
