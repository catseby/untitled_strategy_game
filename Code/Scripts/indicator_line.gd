extends MeshInstance3D

var right = 0.1
var down = 0.1

func generate_line(array : Array[Vector3]):
	var vertices = PackedVector3Array()
	
	array.push_front(Vector3.ZERO)
	
	for i in array.size():
		var cell_pos = array[i] * Vector3(2,0,2)
		
		vertices.push_back(cell_pos + Vector3(right,0,down))
		vertices.push_back(cell_pos + Vector3(-right,0,down))
		vertices.push_back(cell_pos + Vector3(right,0,-down))
		
		vertices.push_back(cell_pos + Vector3(-right,0,down))
		vertices.push_back(cell_pos + Vector3(-right,0,-down))
		vertices.push_back(cell_pos + Vector3(right,0,-down))
		
		if i == array.size() - 1:
			break
		
		var next_cell_pos = array[i+1] * Vector3(2,0,2)
		var dir = array[i].direction_to(array[i+1])
		
		match dir:
			Vector3.RIGHT:
				vertices.push_back(cell_pos + Vector3(right,0,down))
				vertices.push_back(cell_pos + Vector3(right,0,-down))
				vertices.push_back(next_cell_pos + Vector3(-right,0,-down))
				
				vertices.push_back(next_cell_pos + Vector3(-right,0,down))
				vertices.push_back(next_cell_pos + Vector3(-right,0, -down))
				vertices.push_back(cell_pos + Vector3(right,0,down))
			
			Vector3.LEFT:
				vertices.push_back(cell_pos + Vector3(-right,0, -down))
				vertices.push_back(cell_pos + Vector3(-right,0,down))
				vertices.push_back(next_cell_pos + Vector3(right,0,down))
				
				vertices.push_back(next_cell_pos + Vector3(right,0,-down))
				vertices.push_back(next_cell_pos + Vector3(right,0, down))
				vertices.push_back(cell_pos + Vector3(-right,0,-down))
			
			Vector3.FORWARD:
				vertices.push_back(cell_pos + Vector3(right,0, -down))
				vertices.push_back(cell_pos + Vector3(-right,0,-down))
				vertices.push_back(next_cell_pos + Vector3(right,0,down))
				
				vertices.push_back(next_cell_pos + Vector3(right,0, down))
				vertices.push_back(next_cell_pos + Vector3(-right,0, down))
				vertices.push_back(cell_pos + Vector3(-right,0,-down))
			
			Vector3.BACK:
				vertices.push_back(cell_pos + Vector3(-right,0, down))
				vertices.push_back(cell_pos + Vector3(right,0, down))
				vertices.push_back(next_cell_pos + Vector3(-right,0,-down))
				
				vertices.push_back(next_cell_pos + Vector3(-right,0, -down))
				vertices.push_back(next_cell_pos + Vector3(right,0, -down))
				vertices.push_back(cell_pos + Vector3(right,0,down))

	
	
	vertices.push_back(array[0])
	vertices.push_back(array[0])

	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	var m = MeshInstance3D.new()
	
	print(m)
	m.mesh = arr_mesh
	
	mesh = m.mesh
