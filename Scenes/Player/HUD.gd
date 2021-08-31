extends Node
class_name HUD

export(int) var max_health = 20

export(Mesh) var heart_mesh = null
export(String) var hearts_pool = "../Rotation_Helper/Camera/hearts"

var health
var hearts_node

func add_heart(heart_amount):
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = heart_mesh
	mesh_instance.name = "hearth" + str(heart_amount)
	mesh_instance.scale = Vector3(0.25, 0.25, 0.25)
	
	if not heart_amount % 2:
		mesh_instance.rotation_degrees = Vector3(90, 180, 0)
		mesh_instance.translation = Vector3((heart_amount - 2) * 0.6, 0, 0)
	else:
		mesh_instance.rotation_degrees = Vector3(90, 0, 0)
		mesh_instance.translation = Vector3(0.031 + (heart_amount - 1) * 0.6, 0, -0.1)
	
	
	hearts_node.add_child(mesh_instance)
	

func remove_hearth(hearth_amount):
	get_node("../Rotation_Helper/Camera/hearts/heart" + str(hearth_amount)).queue_free()

func display_health():
	var hearth_amount = hearts_node.get_child_count()
	
	if hearth_amount > health:
		print("Removing hearth(s)")
		remove_hearth(hearth_amount - 1)
		
	elif hearth_amount < health:
		print("Adding heath(s)")
		add_heart(hearth_amount + 1)


func _init():
	pass


func _ready():
	health = max_health
	hearts_node = get_node("../Rotation_Helper/Camera/hearts")


func _process(delta):
	display_health()
