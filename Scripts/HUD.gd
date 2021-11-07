extends Node
class_name HUD

export(int) var max_health = 20

export(Mesh) var heart_mesh = null
export(String) var hearts_pool = "../Rotation_Helper/Camera/hearts"

var health
var hearts_node

var inventory_space = 42
var inventory = []
var library
var selected_item = 1
var slot_default_color = Color(0, 0, 0, 84)
var slot_selected_color = Color(0, 0, 0, 100)
var times := []  # Timestamps of frames rendered in the last second
var fps := 0  # Frames per second


func _switch_items(array, first_place, second_place):
	var temp_item = array[second_place]
	
	array[second_place] = inventory[first_place]
	array[first_place] = temp_item
	
	return array


func _read_file(file_path):
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


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


func init_inventory():
	inventory.clear()
	
	for _index in range(inventory_space):
		inventory.append(0)


func add_id_item(id):
	for index in range(0, inventory_space):
		if inventory[index] == 0:
			inventory[index] = id
			return true
	return false


func add_string_item(item):
	var index = 0
	var id
	for current_item in library:
		if current_item["name"] == item:
			id = index
		else:
			return false
		index += 1
	
	return add_id_item(id)


func remove_item(place):
	inventory[place] = 0


func move_items(original_place, new_place):
	if inventory[original_place] == 0:
		return false
	
	_switch_items(inventory, original_place, new_place)


func update_inventory():
	update_hotbar()
	update_main_inventory()


func update_hotbar():
	for index in range(0, 10):
		if library[inventory[index]]["icon"] != null:
			get_item_node(index).texture = load(library[inventory[index]]["icon"])


func update_main_inventory():
	for index in range(10, 42):
		if library[inventory[index]]["icon"] != null:
			get_item_node(index).texture = load(library[inventory[index]]["icon"])


func get_item_node(number):
	if number < 10:
		return get_node("hotbar/toolbox" + str(number) + "/Item")
	else:
		return get_node("inventory/Slots/toolbox" + str(number) + "/Item")


func get_toolbox_node(number):
	if number < 10:
		return get_node("hotbar/toolbox" + str(number))
	else:
		return get_node("inventory/Slots/toolbox" + str(number))


func update_selected_item():
	get_toolbox_node(selected_item+1)


func _ready():
	health = max_health
	hearts_node = get_node("../Rotation_Helper/Camera/hearts")
	var yaml = preload("res://addons/godot-yaml/gdyaml.gdns").new()
	
	library = yaml.parse(_read_file("res://config/ItemLibrary.yaml"))
	print(library[3])
	init_inventory()
	
	for _x in range(0,10):
		add_id_item(3)
	for _x in range(0,20):
		add_id_item(2)


func _process(_delta):
	# ----------------------------------
	# show fps
	var now := OS.get_ticks_msec() 
	
	# Remove frames older than 1 second in the `times` array
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front()

	times.append(now)
	fps = times.size()

	# Display FPS in the label
	$information/fps_label.text = str(fps) + " FPS"
	
	# ----------------------------------
	
	display_health()
	update_inventory()
