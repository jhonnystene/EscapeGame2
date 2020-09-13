extends Spatial

var mesh = Mesh.new()
var color = Color(255, 0, 0)

const TERRAIN_TYPE_ROCKY = 1
const TERRAIN_TYPE_HILLY = 3
const TERRAIN_TYPE_FLAT = 20

const TERRAIN_MULTIPLIER_NORMAL = 1
const TERRAIN_MULTIPLIER_BIGBOI = 2
const TERRAIN_MULTIPLIER_AMPLIFIED = 5

const CHUNK_SIZE = 32
const CHUNK_COUNT = 2
const NOISE_MULTIPLIER = TERRAIN_MULTIPLIER_NORMAL

var noise = OpenSimplexNoise.new()
var chunk = preload("res://Chunk.tscn")
var testRock = preload("res://TestRock.tscn")

func getNoise(x, z):
	return noise.get_noise_2d(x, z) * NOISE_MULTIPLIER

func getVertices(x, z):
	var vertices = PoolVector3Array()
	
	vertices.push_back(Vector3(x, getNoise(x, z), z))
	vertices.push_back(Vector3(x + 1, getNoise(x + 1, z), z))
	vertices.push_back(Vector3(x, getNoise(x, z + 1), z + 1))
	
	vertices.push_back(Vector3(x, getNoise(x, z + 1), z + 1))
	vertices.push_back(Vector3(x + 1, getNoise(x + 1, z), z))
	vertices.push_back(Vector3(x + 1, getNoise(x + 1, z + 1), z + 1))
	
	return vertices
	
func getUVs(x, z):
	var UVs = PoolVector2Array()
	
	UVs.push_back(Vector2(x, z))
	UVs.push_back(Vector2(x + 1, z))
	UVs.push_back(Vector2(x, z + 1))
	
	UVs.push_back(Vector2(x, z + 1))
	UVs.push_back(Vector2(x + 1, z))
	UVs.push_back(Vector2(x + 1, z + 1))
	
	return UVs

func createChunk(chunkX, chunkZ):
	for x in range(chunkX * CHUNK_SIZE, (chunkX * CHUNK_SIZE) + CHUNK_SIZE):
		for z in range(chunkZ * CHUNK_SIZE, (chunkZ * CHUNK_SIZE) + CHUNK_SIZE):
			var vertices = getVertices(x, z)
			var UVs = getUVs(x, z)
			
			var currentChunk = chunk.instance()
			currentChunk.init(vertices, UVs)
			
			self.add_child(currentChunk)
			
	if(randi()%10+1 == 5):
		var rockX = randi()%CHUNK_SIZE + (chunkX * CHUNK_SIZE)
		var rockZ = randi()%CHUNK_SIZE + (chunkZ * CHUNK_SIZE)
		
		var rock = testRock.instance()
		rock.global_translate(Vector3(rockX, 0, rockZ))
		self.add_child(rock)

func _ready():
	randomize()
	
	var grassMaterial = load("res://material.tres")
	
	noise.seed = randi()
	noise.octaves = 1
	noise.persistence = 0.8
	noise.period = TERRAIN_TYPE_HILLY
	
	for x in range(0, CHUNK_COUNT):
		for z in range(0, CHUNK_COUNT):
			createChunk(x, z)
	
func _process(delta):
	var pos = $Player.get_global_transform().origin
	$UILayer/Control/PositionLabel.text = "XYZ: " + str(pos.x) + "," + str(pos.y) + "," + str(pos.z)
	$UILayer/Control/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
