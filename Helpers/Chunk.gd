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
	
	var collisionshape = ConvexPolygonShape.new()
	collisionshape.set_points(vertices)
	$StaticBody/CollisionShape.shape = collisionshape
	
	mesh = generatedMesh
	
	global_translate(Vector3(originX, 0, originZ))
