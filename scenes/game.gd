extends Spatial

export(Material) var terrain_mat = SpatialMaterial.new()
export(Material) var water_mat = SpatialMaterial.new()
export(Color) var water_color = Color(0, 0, 1, 0.8)
export(int) var max_terrain_size = 500
export(int) var detail = 30  # Higher number means less detail
export(int) var mountain_height = 100
export(float) var water_height = -0.08
export(float) var beach_size = 0.68
export(float) var forest_size = 0.2

var noise = OpenSimplexNoise.new()

func make_terrain():
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	var normals = PoolVector3Array()
	var colors = PoolColorArray()
	var indeces = PoolIntArray()

	# Configure
	noise.seed = randi()*0.9
	noise.octaves = 4
	noise.period = 100.0
	noise.persistence = 0.5
	
	var noise_temp
	
	# -------------------------------
	# Mountain generator
	for index_x in max_terrain_size:
		for index_z in max_terrain_size:
			noise_temp = noise.get_noise_2d(index_x, index_z)
			
			vertices.push_back(Vector3(index_x*detail, noise_temp*mountain_height*10, index_z*detail))
			#normals.push_back(Vector3(-1, 0, 0))
			
			# -------------------------------
			# Colors
			if noise_temp <= 0:
				if -noise_temp*3 < beach_size and -noise_temp*3 > forest_size:
					colors.push_back(Color(0, -noise_temp*3, 0, 1))
				elif -noise_temp*3 < forest_size:
					# output = output_start + ((output_end - output_start) / (input_end - input_start)) * (input - input_start)
					colors.push_back(Color(0.335 + ((0.47 - 0.335) / forest_size) * (-noise_temp*3), 0.22, 0, 1))
				else:
					colors.push_back(Color(1, 0.65, 0, 1))
			else:
				if noise_temp < 0.2:
					colors.push_back(Color(0, 0.3 + ((1.0 - 0.3) / 0.2) * noise_temp , 0, 1))
				elif noise_temp < 0.28:
					colors.push_back(Color(0.6, 0.6, 0.6, 1))
				elif noise_temp < 0.32:
					colors.push_back(Color(0.8, 0.8, 0.8, 1))
				else:
					colors.push_back(Color(1, 1, 1, 1))
			# -------------------------------
	
	for index in (max_terrain_size-1)*max_terrain_size:
		if not (index+1) % max_terrain_size == 0:
			indeces.push_back(index+max_terrain_size)
			indeces.push_back(index+1)
			indeces.push_back(index)
			
			indeces.push_back(index+1)
			indeces.push_back(index+max_terrain_size)
			indeces.push_back(index+max_terrain_size+1)
	# -------------------------------
	
	var surface_tool = SurfaceTool.new();
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
	
	terrain_mat.vertex_color_use_as_albedo = true
	surface_tool.set_material(terrain_mat)
	
	for index in vertices.size():
		#surface_tool.add_normal(normals[index])
		surface_tool.add_color(colors[index])
		surface_tool.add_vertex(vertices[index])
	
	for index in indeces.size():
		surface_tool.add_index(indeces[index])
	
	$terrain.mesh = surface_tool.commit()
	$terrain.create_trimesh_collision()

func make_water():
	var vertices = PoolVector3Array()
	var indeces = PoolIntArray()
	
	vertices.push_back(Vector3(0, water_height*detail*mountain_height, 0))
	vertices.push_back(Vector3(0, water_height*detail*mountain_height, max_terrain_size*detail))
	vertices.push_back(Vector3(max_terrain_size*detail, water_height*detail*mountain_height, 0))
	vertices.push_back(Vector3(max_terrain_size*detail, water_height*detail*mountain_height, max_terrain_size*detail))
	
	indeces.push_back(0)
	indeces.push_back(1)
	indeces.push_back(2)
	
	indeces.push_back(1)
	indeces.push_back(2)
	indeces.push_back(3)
	
	indeces.push_back(2)
	indeces.push_back(1)
	indeces.push_back(0)
	
	indeces.push_back(3)
	indeces.push_back(2)
	indeces.push_back(1)
	
	var surface_tool = SurfaceTool.new();
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
	
	water_mat.set_albedo(water_color)
	
	surface_tool.set_material(water_mat)
	
	for index in vertices.size():
		surface_tool.add_vertex(vertices[index])
	
	for index in indeces.size():
		surface_tool.add_index(indeces[index])
	
	$water.mesh = surface_tool.commit()
	

func _ready():
	make_terrain()
	make_water()

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
