extends Spatial
class_name Chunk

export(int) var water_amount = 1  # higher number means less water
export(float) var tree_amount = 0.5  # higher number means more trees

export(float) var terrain_detail = 1
export(float) var water_detail = 3

const water_material = "res://material/shaders/enviroment/water.material"
const terrain_material = "res://material/shaders/enviroment/terrain.material"
const grass_blade_material = "res://material/shaders/enviroment/grass_blades.material"

var tree = preload("res://Scenes/props/Tree.scn")

var rng = RandomNumberGenerator.new()

var should_remove
var noise
var x
var z
var chunk_size
var thread

func _init(global_noise, global_x, global_z, global_chunk_size):
	self.noise = global_noise
	self.x = global_x
	self.z = global_z
	self.chunk_size = global_chunk_size


func _ready():
	thread = Thread.new()
	rng.randomize()
	
	generate_chunk()
	generate_water()

func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * terrain_detail
	plane_mesh.subdivide_width = chunk_size * terrain_detail
	plane_mesh.material = preload(terrain_material)
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var data_tool = MeshDataTool.new()
	var array_plane = surface_tool.commit()
	var _error = data_tool.create_from_surface(array_plane, 0)
	
	# init multimesh for grass blades
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = data_tool.get_vertex_count()
	multimesh.visible_instance_count = -1
	multimesh.mesh = preload("res://Models/world/grass_blade.obj")
	
	for index in range(data_tool.get_vertex_count()):
		# set vertex height
		var vertex = data_tool.get_vertex(index)
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 80 + water_amount
		
		data_tool.set_vertex(index, vertex)
		
		# generate grass blades
		multimesh.set_instance_transform(index, Transform(Basis(), vertex))
		
		# generate trees
		if rand_range(0, 100) < tree_amount and vertex.y > 2:
			var tree_instance = tree.instance()
			tree_instance.translation = Vector3(vertex.x, vertex.y-1, vertex.z)
			add_child(tree_instance)
	
	for index in range(array_plane.get_surface_count()):
		array_plane.surface_remove(index)
	
	
	# edit terrain parameters
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	# create mesh instance for the terrain
	var mesh_instance = MeshInstance.new()
	mesh_instance.name = "terrain"
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
	
	# create multimesh instance for the grass blades
	var multimesh_instance = MultiMeshInstance.new()
	multimesh_instance.multimesh = multimesh
	multimesh_instance.material_override = preload(grass_blade_material)
	add_child(multimesh_instance)


func generate_water():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * water_detail
	plane_mesh.subdivide_width = chunk_size * water_detail
	plane_mesh.material = preload(water_material)
	plane_mesh.material.set_shader_param("absolute_pos", Vector2(float(x), float(z)))
	
	var water_mesh_instance = MeshInstance.new()
	water_mesh_instance.mesh = plane_mesh
	water_mesh_instance.name = "water"
	
	add_child(water_mesh_instance)
