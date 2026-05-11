extends Camera3D

const RAY_LENGTH = 1000.0

@export var target_path: NodePath: get = get_target_path, set = set_garget_path
@export var blend := 0.5

# Camera settings
@export var distance : float = 10.0
@export var min_distance : float = 5.0
@export var max_distance : float = 25.0
@export var zoom_speed : float = 0.5

# Rotation settings
@export var rotation_speed : float = 0.005
@export var min_pitch : float = -1.4  # ~-80 degrees
@export var max_pitch : float = 1.4   # ~80 degrees

@export var grabber_force := 1.0

signal grabber_target_changed(target: RigidBody3D)

var _target: Node3D
var _target_path: NodePath

# Rotation variables
var _yaw : float = 0.0
var _pitch : float = 0.5  # Start slightly above


var _grabber_point: Vector3
var _grabber_target: RigidBody3D = null



func get_target_path() -> NodePath:
	return _target_path

func set_garget_path(value: NodePath) -> void:
	_target_path = value
	_target = get_node_or_null(value)
	#print("T=", value)


func _ready() -> void:
	set_garget_path(target_path)
	update_camera_position()


func _physics_process(_delta: float) -> void:
	update_camera_position()
	# if _target:
	# 	var need = _target.global_position + offset
	# 	position = position.lerp(need, blend)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# Rotate camera with right mouse button
			_yaw -= event.relative.x * rotation_speed
			_pitch += event.relative.y * rotation_speed
			_pitch = clamp(_pitch, min_pitch, max_pitch)
			update_camera_position()
		elif _grabber_target:
			var mouse_pos = get_viewport().get_mouse_position()
			var from = project_ray_origin(mouse_pos)
			_grabber_point = from + project_ray_normal(mouse_pos) * (_grabber_point - position).length()
	
	if event is InputEventMouseButton:
		# Zoom with mouse wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clamp(distance - zoom_speed, min_distance, max_distance)
			update_camera_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clamp(distance + zoom_speed, min_distance, max_distance)
			update_camera_position()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var result = shoot_ray()
				if result and result.collider is RigidBody3D:
					# print(result.collider.name)
					# print(result)
					_grabber_point = result.position
					_grabber_target = result.collider
					# set_garget_path(_grabber_target.get_path())
					grabber_target_changed.emit(_grabber_target)
			else: # event.released
				_grabber_target = null


func update_camera_position():
	var target_pos := Vector3.ZERO
	if _target:
		target_pos = _target.global_position

	# Calculate new position based on spherical coordinates
	var offset = Vector3.ZERO
	offset.x = distance * sin(_yaw) * cos(_pitch)
	offset.y = distance * sin(_pitch)
	offset.z = distance * cos(_yaw) * cos(_pitch)
	
	# Update camera position and look at target
	position = target_pos + offset

	look_at(target_pos, Vector3.UP)


func shoot_ray() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return get_world_3d().direct_space_state.intersect_ray(query)




