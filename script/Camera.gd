extends Camera3D

const RAY_LENGTH = 1000.0


@export var target_path: NodePath: get = get_target_path, set = set_garget_path
@export var offset: Vector3
@export var blend := 0.5

@export var grabber_force := 1.0

signal grabber_target_changed(target: RigidBody3D)

var _target: Node3D
var _target_path: NodePath

func get_target_path() -> NodePath:
	return _target_path

func set_garget_path(value: NodePath) -> void:
	_target_path = value
	_target = get_node_or_null(value)
	#print("T=", value)


func _ready() -> void:
	set_garget_path(target_path)


func _physics_process(_delta: float) -> void:
	if _target:
		var need = _target.global_position + offset
		position = position.lerp(need, blend)

	if _grabber_target:
		_grabber_target.apply_force((_grabber_point - _grabber_target.global_position) * grabber_force)



var _grabber_point: Vector3
var _grabber_target: RigidBody3D = null

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
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
	elif event is InputEventMouseMotion:
		if _grabber_target:
			var mouse_pos = get_viewport().get_mouse_position()
			var from = project_ray_origin(mouse_pos)
			_grabber_point = from + project_ray_normal(mouse_pos) * (_grabber_point - position).length()


func shoot_ray() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return get_world_3d().direct_space_state.intersect_ray(query)







