extends Spatial
class_name CustomTree

const trunk_material = "res://material/trunk.material"
const leaf_material = "res://material/leafs.material"

func generate_trunk():
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.height = 8
	trunk_mesh.radial_segments = 8
	trunk_mesh.rings = 0
	trunk_mesh.material = preload(trunk_material)
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = trunk_mesh
	mesh_instance.translation = Vector3(0, 4, 0)
	mesh_instance.create_trimesh_collision()
	
	add_child(mesh_instance)


func generate_leafs():
	var leaf_mesh = SphereMesh.new()
	leaf_mesh.radius = 3
	leaf_mesh.height = 7
	leaf_mesh.radial_segments = 10
	leaf_mesh.rings = 10
	leaf_mesh.material = preload(leaf_material)
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = leaf_mesh
	mesh_instance.translation = Vector3(0, 10, 0)
	mesh_instance.create_trimesh_collision()
	
	add_child(mesh_instance)

func _ready():
	generate_trunk()
	generate_leafs()
