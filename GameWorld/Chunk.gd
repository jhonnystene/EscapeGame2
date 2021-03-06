extends Node2D

var surfaceTool = SurfaceTool.new()
var surfaceToolBelow = SurfaceTool.new()

var minerals = []

func _ready():
	for child in get_parent().get_parent().get_children():
		if("WorldObjectContainer" in child.name):
			for mineral in minerals:
				child.add_child(mineral)

func add_mineral(x, y, mineral):
	mineral.global_translate(Vector2(x, y + rand_range(-1, 0)))
	mineral.global_rotation_degrees = rand_range(-45, 45)
	minerals.append(mineral)

func generate(chunkX, noise):
	name = str(chunkX)
	surfaceTool.begin(Mesh.PRIMITIVE_LINES)
	#surfaceTool.add_color(Color(GlobalData.world_color))
	surfaceTool.set_material(load("res://Materials/GroundMaterial.tres"))
	
	surfaceToolBelow.begin(Mesh.PRIMITIVE_TRIANGLES)
	#surfaceToolBelow.add_color(Color(GlobalData.world_color))
	surfaceToolBelow.set_material(load("res://Materials/GroundMaterial.tres"))
	
	var genX = chunkX * GlobalData.chunkSize
	var generatedMesh = Mesh.new()
	var bottomMesh = Mesh.new()
	
	var segments = []
	var points = []
	
	var mineral = GlobalData.world_get_mineral(chunkX)
	if(mineral):
		add_mineral(genX, noise.get_noise_2d(genX, 1) * GlobalData.terrainMultiplier, mineral)
	
	for x in range(0, GlobalData.chunkSize):
		# First we create a triangle to define the actual terrain
		surfaceTool.add_uv(Vector2(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier))
		surfaceTool.add_vertex(Vector3(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier, 0))
		points.append(Vector2(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier))
		#segments.append(Vector2(genX + x, 10000))
		segments.append(Vector2(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier))
		
		surfaceTool.add_uv(Vector2(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier))
		surfaceTool.add_vertex(Vector3(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier, 0))
		points.append(Vector2(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier))
		#segments.append(Vector2(genX + x + 1, 10000))
		segments.append(Vector2(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier))
		
		surfaceToolBelow.add_uv(Vector2(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier))
		surfaceToolBelow.add_vertex(Vector3(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier, 0))
		surfaceToolBelow.add_uv(Vector2(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier))
		surfaceToolBelow.add_vertex(Vector3(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier, 0))
		surfaceToolBelow.add_uv(Vector2(genX + x, 10000))
		surfaceToolBelow.add_vertex(Vector3(genX + x, 10000, 0))

		surfaceToolBelow.add_uv(Vector2(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier))
		surfaceToolBelow.add_vertex(Vector3(genX + x, noise.get_noise_2d(genX + x, 1) * GlobalData.terrainMultiplier, 0))
		surfaceToolBelow.add_uv(Vector2(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier))
		surfaceToolBelow.add_vertex(Vector3(genX + x + 1, noise.get_noise_2d(genX + x + 1, 1) * GlobalData.terrainMultiplier, 0))
		surfaceToolBelow.add_uv(Vector2(genX + x + 1, 10000))
		surfaceToolBelow.add_vertex(Vector3(genX + x + 1, 10000, 0))

	points.append(Vector2(genX + GlobalData.chunkSize, 10000))
	points.append(Vector2(genX, 10000))
	points.append(Vector2(genX, noise.get_noise_2d(genX, 1) * GlobalData.terrainMultiplier))
	
	surfaceToolBelow.commit(bottomMesh)
	$FillerMesh.set_mesh(bottomMesh)
	#$FillerMesh.material = load("res://Materials/GroundShaderMaterial.tres")
	
	surfaceTool.commit(generatedMesh)
	$DisplayMesh.set_mesh(generatedMesh)
	#$DisplayMesh.material = load("res://Materials/GroundShaderMaterial.tres")
	var collisionShape
	if(GlobalData.collisionType == GlobalData.COLLISION_TYPE_CONVEX):
		collisionShape = ConvexPolygonShape2D.new()
		for point in generatedMesh.get_faces():
			points.append(Vector2(point.x, point.y))
		collisionShape.set_points(points)
	else:
		collisionShape = ConcavePolygonShape2D.new()
		collisionShape.set_segments(segments)
	
	$GroundCollision/CollisionShape.shape = collisionShape
