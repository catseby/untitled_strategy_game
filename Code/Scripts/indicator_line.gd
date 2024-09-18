extends MeshInstance3D

@export var line_width = 0.1
var right = line_width
var down = line_width

func generate_line(array : Array[Vector3]):
	var vertices = PackedVector3Array()
	

	
	array.push_front(Vector3.ZERO)
	array[array.size()-1] = array[array.size()-2].lerp(array[array.size()-1],0.45)
	#array[array.size()-1] = array[array.size()-1] - Vector3(0.5,0,0)
	print(array[array.size()-1])
	
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
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	var m = MeshInstance3D.new()
	
	m.mesh = arr_mesh
	
	mesh = m.mesh
