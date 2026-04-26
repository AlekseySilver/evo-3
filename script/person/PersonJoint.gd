class_name PersonJoint extends HingeJoint3D


const MAX_MOTOR_TARGET_VELOCITY = 10.0
const MAX_MOTOR_TORQUE = 100.0


@export var limit_speed: float = 10.0
@export var limit_bias: float = 0.01
@export var no_motor_bias: float = 0.01
@export var same_angle_bias: float = 0.001

# default limit in radians
var _default_limit_lower: float
var _default_limit_upper: float

var _target_angle: float
var _limit_speed: float

var _is_limiting := false

var _bodyA: RigidBody3D
var _bodyB: RigidBody3D

var _A2B_zero: Basis
var _local_axis_around_in_B: Vector3

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




func _ready() -> void:
	_default_limit_lower = limit_lower
	_default_limit_upper = limit_upper

	_bodyA = get_node(node_a)
	_bodyB = get_node(node_b)

	var A := _bodyA.global_transform.basis
	var B := _bodyB.global_transform.basis
	_A2B_zero = Xts.term_second(B, A)
	_local_axis_around_in_B = global_transform.basis.z * B

	motor_max_torque = MAX_MOTOR_TORQUE


func _physics_process(delta: float) -> void:
	if _is_limiting:
		var h := delta * _limit_speed
		var l := limit_lower + h
		h = limit_upper - h

		var target_angle_upper := _target_angle + limit_bias

		if l > _target_angle:
			if h < target_angle_upper: # target achieved
				update_limit_angle(_target_angle)
			else:
				limit_lower = _target_angle
				limit_upper = h
		else:
			limit_lower = l
			limit_upper = target_angle_upper if h < target_angle_upper else h


func stop_limit() -> void:
	_is_limiting = false
	motor_enabled = false


func update_limit_angle(angle: float) -> void:
	stop_limit()
	limit_lower = angle
	limit_upper = angle + limit_bias


func relax() -> void:
	stop_limit()
	limit_lower = _default_limit_lower
	limit_upper = _default_limit_upper


func freeze() -> void:
	var angle := clampf(get_current_angle(), _default_limit_lower, _default_limit_upper)
	start_limit_angle(angle)


# range from 0 to 1 (0 - low, 1 - high)
# speed degrees in second
func start_limit_angle(angle: float, speed: float = 1.0, motorate: float = 1.0) -> void:
	relax()
	if motorate > 0.0:
		var current_angle := get_current_angle()
		# var diff := absf(current_angle - _target_angle)
		# if true: #diff > same_angle_bias or not _is_limiting:
			
		_target_angle = angle
		_is_limiting = true
		_limit_speed = speed * limit_speed

		# if diff > no_motor_bias:
		if current_angle < _target_angle:
			limit_upper = _target_angle
			motor_target_velocity = motorate * MAX_MOTOR_TARGET_VELOCITY
		else:
			limit_lower = _target_angle
			motor_target_velocity = motorate * -MAX_MOTOR_TARGET_VELOCITY
		motor_enabled = true
	# else:
	# 	relax()


func get_current_motorate() -> float:
	return absf(motor_target_velocity) / MAX_MOTOR_TARGET_VELOCITY


# range from 0 to 1 (0 - low, 1 - high)
# speed degrees in second
func start_limit(range_: float, speed: float = 1.0, motorate: float = 1.0) -> void:
	start_limit_angle(get_angle(range_), speed, motorate)


func get_current_range() -> float:
	return get_range(get_current_angle())


func get_range(angle: float) -> float:
	return (angle - _default_limit_lower) / (_default_limit_upper - _default_limit_lower)


# angle Between limits
# range from 0 to 1
func get_angle(range_: float) -> float:
	return lerpf(_default_limit_lower, _default_limit_upper, range_)


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





