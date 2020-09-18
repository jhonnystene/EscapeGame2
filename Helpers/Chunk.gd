extends MeshInstance

func init(originX, originZ, vertices, UVs):
	var grassMaterial = load("res://Materials/GroundMaterial.tres")
	var generatedMesh = Mesh.new()
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(grassMaterial)

	for v in vertices.size(): 
		#st.add_color(color)
		st.add_uv(UVs[v])
		st.add_vertex(vertices[v])

	st.generate_normals()
	st.generate_tangents()

	st.commit(generatedMesh)
	
	var triangleCount = len(vertices) / 3
	var quadCount = triangleCount / 2
	var chunkSize = sqrt(quadCount)
	
	var subchunkSize = 4
	var subchunkCount = int(chunkSize / subchunkSize) * int(chunkSize / subchunkSize)
	
	var vertexCountPerSubchunk = (subchunkSize * subchunkSize * 3 * 2)
	
	for subchunkID in range(0, subchunkCount):
		#print("Generating Subchunk " + str(subchunkID) + "/" + str(subchunkCount) + " (" + str(vertexCountPerSubchunk) + " vertices)")
		var subchunk = PoolVector3Array()
		
		for vertexID in range(0, vertexCountPerSubchunk):
			subchunk.push_back(vertices[(subchunkID * vertexCountPerSubchunk) + vertexID])
		
		createCollisionShape(subchunk)
		
	mesh = generatedMesh
	
	global_translate(Vector3(originX, 0, originZ))

func createCollisionShape(vertices):
	var collider = load("res://Helpers/Collider.tscn")
	
	var collisionshape = ConvexPolygonShape.new()
	collisionshape.set_margin(0.01)
	collisionshape.set_points(vertices)
	
	var colliderInstance = collider.instance()
	colliderInstance.get_children()[0].shape = collisionshape
	add_child(colliderInstance)
	
