extends KinematicBody

# Flying
export var free_fly = false
export var max_fly_speed = 200
export var max_vertical_fly_speed = 70

# Vertical Forces
export var gravity = -45
export var water_up_force = 35

# Jumping
export var jump_speed = 18

# Walking
export var max_speed = 20
export var max_sprint_speed = 30
export var accel = 4.5
export var deaccel= 16
export var max_slope_angle = 40

# Mouse
export var mouse_sensivity = 0.05


var vel = Vector3()
var dir = Vector3()

var camera
var rotation_helper
var is_sprinting = false

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backwards"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
	else:
		is_sprinting = false

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor() and free_fly == false:
		if Input.is_action_just_pressed("jump"):
			vel.y = jump_speed
	# ----------------------------------
	
	# ----------------------------------
	# inventory
	
	if Input.is_action_just_pressed("inventory"):
		$HUD/inventory.visible = !$HUD/inventory.visible
		if $HUD/inventory.visible == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# ----------------------------------
	
	# ----------------------------------
	# fly
	if Input.is_action_just_pressed("debug"):
		free_fly = !free_fly
	
	if free_fly == true:
		vel.y = 0
		if Input.is_action_pressed("jump"):
			vel.y = max_vertical_fly_speed
		if Input.is_action_pressed("crouch"):
			vel.y = water_up_force
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			$pause_menu.hide()
			$HUD.show()
			$Rotation_Helper/Camera/hearts.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			$pause_menu.show()
			$HUD.hide()
			$HUD/inventory.visible = false
			$Rotation_Helper/Camera/hearts.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	if free_fly == false and self.translation.y > 1:
		vel.y += delta * gravity
	elif self.translation.y < 1:
		vel.y += delta * water_up_force

	var hvel = vel
	hvel.y = 0

	var target = dir
	if free_fly == false and is_sprinting == false:
		target *= max_speed
	elif is_sprinting == true:
		target *= max_sprint_speed
	else:
		target *= max_fly_speed

	var current_accel
	if dir.dot(hvel) > 0:
		current_accel = accel
	else:
		current_accel = deaccel

	hvel = hvel.linear_interpolate(target, current_accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(max_slope_angle))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * mouse_sensivity))
		self.rotate_y(deg2rad(event.relative.x * mouse_sensivity * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
