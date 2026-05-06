class_name MuscleJoint extends HingeJoint3D


var _bodyA: RigidBody3D
var _bodyB: RigidBody3D

var _A2B_zero: Basis
var _local_axis_around_in_B: Vector3

func _ready() -> void:
	_bodyA = get_node(node_a)
	_bodyB = get_node(node_b)

	var A := _bodyA.global_transform.basis
	var B := _bodyB.global_transform.basis
	_A2B_zero = Xts.term_second(B, A)
	_local_axis_around_in_B = global_transform.basis.z * B


func _physics_process(_delta: float) -> void:
	update_motor()


#region LIMIT

var limit_lower: float:
	set(new_value):
		set_param(Param.PARAM_LIMIT_LOWER, new_value)
	get():
		return get_param(Param.PARAM_LIMIT_LOWER) # тут вроде ок -- godot error выдается 180 на границах


var limit_upper: float:
	set(new_value):
		set_param(Param.PARAM_LIMIT_UPPER, new_value) # !!!todo godot error выдается 180 на границах
	get():
		return get_param(Param.PARAM_LIMIT_UPPER) # !!!todo godot error выдается 180 на границах

func get_angle_limit_clamped(angle: float) -> float:
	return clampf(angle, rad_to_deg(limit_lower), rad_to_deg(limit_upper))


#endregion


#region MOTOR

@export var motor_target_rate: float = 0.5

var motor_max_torque: float:
	set(new_value):
		set_param(Param.PARAM_MOTOR_MAX_IMPULSE, new_value)
	get():
		return get_param(Param.PARAM_MOTOR_MAX_IMPULSE)

var motor_target_velocity: float:
	set(new_value):
		set_param(Param.PARAM_MOTOR_TARGET_VELOCITY, new_value)
	get():
		return get_param(Param.PARAM_MOTOR_TARGET_VELOCITY)

var motor_enabled: bool:
	set(new_value):
		set_flag(Flag.FLAG_ENABLE_MOTOR, new_value)
	get():
		return get_flag(Flag.FLAG_ENABLE_MOTOR)

var _target_angle: float

func update_motor() -> void:
	motor_target_velocity = (_target_angle - get_current_angle_deg()) * motor_target_rate

func start_target_angle(angle: float) -> void:
	_target_angle = get_angle_limit_clamped(angle)
	motor_enabled = true

func stop_target() -> void:
	motor_enabled = false


func get_current_angle() -> float:
	var A := _bodyA.global_transform.basis
	var B := _bodyB.global_transform.basis

	# b = a + a2b
	# a2b = z + d
	# b = a + z + d
	var delta := Xts.term_second(B, A * _A2B_zero)
	var q := delta.get_rotation_quaternion()
	var angle := q.get_angle()
	if q.get_axis().dot(_local_axis_around_in_B) > 0.0:
		angle = -angle
	if angle > PI:
		angle += PI * -2.0
	elif angle < -PI:
		angle += PI * 2.0
	return angle


func get_current_angle_deg() -> float:
	return rad_to_deg(get_current_angle())


var target_angle_range: float:
	set(new_value):
		var l := limit_lower
		var u := limit_upper
		start_target_angle(rad_to_deg(lerpf(l, u, new_value)))
	get():
		var l := limit_lower
		var u := limit_upper
		if u > l:
			return (deg_to_rad(_target_angle) - l) / (u - l)
		return 0.0

#endregion



