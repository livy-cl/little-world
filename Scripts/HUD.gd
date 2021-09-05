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
	
	for index in range(inventory_space):
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


func sort_inventory():
	var temp_toolbar = inventory
	var temp_inventory = inventory
	var inventorys = [temp_toolbar, temp_inventory]
	
	# --------------------------
	# sorting inventory
	temp_toolbar.erase(null)
	for index in temp_toolbar.size():
		if temp_toolbar[index].item["sort"] == null:
			temp_toolbar.remove[index]
	
	var sorted = 0
	var previous_item
	
	for current_inventory in inventorys:
		sorted = 0
		while sorted == current_inventory.size():
			previous_item = null
			sorted = 0
			
			for index in current_inventory.size():
				if previous_item != null:
					if previous_item > library[current_inventory[index]]["sort"]:
						current_inventory = _switch_items(current_inventory, index, index-1)
					else:
						sorted += 1
				else:
					sorted += 1
				
				previous_item = library[current_inventory[index]]["sort"]
	
	# --------------------------
	# done
	temp_toolbar.append_array(temp_inventory)
	inventory = temp_toolbar

func update_inventory():
	update_hotbar()
	update_main_inventory()


func update_hotbar():
	var texture
	
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
	init_inventory()
	
	for x in range(0,10):
		add_id_item(1)
	for x in range(0,20):
		add_id_item(2)


func _process(delta):
	display_health()
	update_inventory()
