extends Spatial
class_name Chunk

export(int) var water_amount = 15  # higher number means less water
export(int) var tree_amount = 1.5  # higher number means more trees

const water_material = "res://material/water.material"
const terrain_material = "res://material/terrain.material"

var mesh_instance
var noise
var x
var z
var chunk_size
var should_remove = true
var thread

func _init(noise, x, z, chunk_size):
	self.noise = noise
	self.x = x
	self.z = z
	self.chunk_size = chunk_size


func _ready():
	thread = Thread.new()
	
	generate_chunk()
	generate_water()


func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.5
	plane_mesh.subdivide_width = chunk_size * 0.5
	plane_mesh.material = preload(terrain_material)
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var data_tool = MeshDataTool.new()
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	
	for index in range(data_tool.get_vertex_count()):
		# set vertex height
		var vertex = data_tool.get_vertex(index)
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 80 + water_amount
		
		data_tool.set_vertex(index, vertex)
		
		# generate trees
		if rand_range(0, 100) < tree_amount and vertex.y > 2:
			var tree = CustomTree.new()
			tree.translation = Vector3(vertex.x, vertex.y-1, vertex.z)
			add_child(tree)
	
	for index in range(array_plane.get_surface_count()):
		array_plane.surface_remove(index)
	
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)


func generate_water():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.material = preload(water_material)
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = plane_mesh
	
	add_child(mesh_instance)
