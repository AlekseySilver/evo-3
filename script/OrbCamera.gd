extends Camera3D


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


var _target: Node3D
var _target_path: NodePath


# Rotation variables
var _yaw : float = 0.0
var _pitch : float = 0.5  # Start slightly above


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
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# Rotate camera with right mouse button
		_yaw -= event.relative.x * rotation_speed
		_pitch += event.relative.y * rotation_speed
		_pitch = clamp(_pitch, min_pitch, max_pitch)
		update_camera_position()
	
	if event is InputEventMouseButton:
		# Zoom with mouse wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clamp(distance - zoom_speed, min_distance, max_distance)
			update_camera_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clamp(distance + zoom_speed, min_distance, max_distance)
			update_camera_position()

func update_camera_position():
	if _target:
		# Calculate new position based on spherical coordinates
		var offset = Vector3.ZERO
		offset.x = distance * sin(_yaw) * cos(_pitch)
		offset.y = distance * sin(_pitch)
		offset.z = distance * cos(_yaw) * cos(_pitch)
		
		# Update camera position and look at target
		position = _target.global_position + offset

		look_at(_target.global_position, Vector3.UP)