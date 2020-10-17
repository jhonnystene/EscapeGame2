extends Node2D

var surfaceTool = SurfaceTool.new()
var surfaceToolBelow = SurfaceTool.new()

func add_mineral(x, y, mineral):
	mineral = mineral.instance()
	mineral.global_translate(Vector2(x, y + rand_range(-1, 0)))
	mineral.global_rotation_degrees = rand_range(-45, 45)
	add_child(mineral)

func generate(chunkX, noise):
	name = str(chunkX)
	surfaceTool.begin(Mesh.PRIMITIVE_LINES)
	surfaceTool.add_color(Color(GlobalData.world_color))
	
	surfaceToolBelow.begin(Mesh.PRIMITIVE_TRIANGLES)
	surfaceToolBelow.add_color(Color(GlobalData.world_color))
	
	var genX = chunkX * GlobalData.chunkSize
	var generatedMesh = Mesh.new()
	var bottomMesh = Mesh.new()
	
	var segments = []
	var points = []
	
	if(int(rand_range(0, 10)) == 5):
		add_mineral(genX, noise.get_noise_2d(genX, 1) * GlobalData.terrainMultiplier, GlobalData.testMineral)
	
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
	
	surfaceTool.commit(generatedMesh)
	$DisplayMesh.set_mesh(generatedMesh)
	
	var collisionShape
	if(GlobalData.collisionType == GlobalData.COLLISION_TYPE_CONVEX):
		collisionShape = ConvexPolygonShape2D.new()
		for point in generatedMesh.get_faces():
			points.append(Vector2(point.x, point.y))
		collisionShape.set_points(points)
	else:
		collisionShape = ConcavePolygonShape2D.new()
		collisionShape.set_segments(segments)
	
	$Collision/CollisionShape.shape = collisionShape
