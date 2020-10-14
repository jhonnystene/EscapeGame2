extends Node2D

var surfaceTool = SurfaceTool.new()
	
func generate(chunkX, noise):
	surfaceTool.begin(Mesh.PRIMITIVE_LINES)
	surfaceTool.add_color(Color(1, 1, 1))
	var genX = chunkX * GlobalData.chunkSize
	var generatedMesh = Mesh.new()
	
	var segments = []
	var points = []
	
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
	points.append(Vector2(genX + GlobalData.chunkSize, 10000))
	points.append(Vector2(genX, 10000))
	points.append(Vector2(genX, noise.get_noise_2d(genX, 1) * GlobalData.terrainMultiplier))
	
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
