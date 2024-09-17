extends MeshInstance3D

func generate_line(array : Array[Vector3]):
	var vertices = PackedVector3Array()

	
	for i in array.size() - 1:
		vertices.push_back(array[i])
		vertices.push_back(array[i+1])

		#vertices.push_back(array[i] + Vector3(0.1,0,0))
		#vertices.push_back(array[i] + Vector3(-0.1,0,0))
		#vertices.push_back(array[i] + Vector3(0,0,0.1))
		#
		#vertices.push_back(array[i] + Vector3(0.1,0,0))
		#vertices.push_back(array[i] + Vector3(-0.1,0,0))
		#vertices.push_back(array[i] + Vector3(0,0,-0.1))
	
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var m = MeshInstance3D.new()
	
	print(m)
	m.mesh = arr_mesh
	
	mesh = m.mesh
