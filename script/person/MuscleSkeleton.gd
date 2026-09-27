class_name MuscleSkeleton extends Node3D

enum StateType { IDLE, WALK, FALL, STAND_UP, STAND_IDLE, RELAX, BACK_2_FRONT, MOVE }

var _joints: Array[MuscleJoint]

@onready var body_hip: RigidBody3D = $Hip
@onready var head: MuscleJoint = $HJ_Spine3_Head
@onready var spine1: MuscleJoint = $HJ_Hip_Spine1
@onready var spine2: MuscleJoint = $HJ_Spine1_Spine2
@onready var spine3: MuscleJoint = $HJ_Spine2_Spine3

@onready var hip_L: MuscleJoint = $HJL_Hip_Hip
@onready var thigh_L: MuscleJoint = $HJL_Hip_Thigh
@onready var calf_L: MuscleJoint = $HJL_Thigh_Calf
@onready var foot_L: MuscleJoint = $HJL_Calf_Foot
@onready var hip_R: MuscleJoint = $HJR_Hip_Hip
@onready var thigh_R: MuscleJoint = $HJR_Hip_Thigh
@onready var calf_R: MuscleJoint = $HJR_Thigh_Calf
@onready var foot_R: MuscleJoint = $HJR_Calf_Foot

@onready var shoulder_L: MuscleJoint = $HJL_Spine3_Shoulder
@onready var uarm_L: MuscleJoint = $HJL_Shoulder_UArm
@onready var farm_L: MuscleJoint = $HJL_UArm_FArm
@onready var shoulder_R: MuscleJoint = $HJR_Spine3_Shoulder
@onready var uarm_R: MuscleJoint = $HJR_Shoulder_UArm
@onready var farm_R: MuscleJoint = $HJR_UArm_FArm

@onready var _tree: SceneTree = get_tree()
var _state: Array[StateType] = [StateType.IDLE, StateType.IDLE]
var _state_stats: Array = [{}, {}] # Array[ Dictionary[StateType, Dictionary] ]

signal state_changed()

var walk_param := {}

func _ready() -> void:
	PhysicsServer3D.body_add_collision_exception($Head.get_rid(), $Shoulder_L.get_rid())
	PhysicsServer3D.body_add_collision_exception($Head.get_rid(), $Shoulder_R.get_rid())
	PhysicsServer3D.body_add_collision_exception($Shoulder_L.get_rid(), $Shoulder_R.get_rid())

	# var add_joint := func(joint):
	# 	_joints.append(joint)
	# Xts.foreach_child($Skel, add_joint, false, "MuscleJoint")
	Xts.foreach_child(self, func(x): _joints.append(x), false, "HingeJoint3D")
	# print(len(_joints))
	# for joint in _joints:
	# 	print("@onready var calf_R: MuscleJoint = $", joint.name)
	restart_state(0)
	restart_state(1)


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		for j in _joints:
			print(j.name, " angle = ", j.get_current_angle_deg())
	
	if Input.is_key_pressed(KEY_S):
		_state[0] = StateType.MOVE
		print(cycle_state)

		# inner_state = StateType.BACK_2_FRONT
		# print(inner_state)


		# spine3.start_target_angle(0.0)
		# spine1.start_target_angle(0.0)
		# head.start_target_angle(0.0)

		# uarm_L.target_angle_range = 1.0
		# uarm_R.target_angle_range = 1.0
		# farm_L.target_angle_range = 0.9
		# farm_R.target_angle_range = 0.0
		# shoulder_L.target_angle_range = 0.99
		# shoulder_R.target_angle_range = 0.75
		# foot_L.target_angle_range = 0.7
		# foot_R.target_angle_range = 0.7

		# hip_L.target_angle_range = 0.6
		# thigh_L.target_angle_range = 1.0
		# calf_L.target_angle_range = 0.0

		# hip_R.target_angle_range = 0.8
		# thigh_R.target_angle_range = 1.0
		# calf_R.target_angle_range = 0.0

		# spine2.target_angle_range = 0.0

		# await _tree.create_timer(2.0).timeout
		# thigh_L.target_angle_range = 0.0
		# thigh_R.target_angle_range = 0.0

		# await _tree.create_timer(2.0).timeout
		# shoulder_L.target_angle_range = 0.5
		# spine2.target_angle_range = 0.5



func get_state_last_duration_second(level: int, state_: StateType) -> float:
	var stat: Dictionary = _state_stats[level].get(state_)
	if stat:
		var d: int = stat["duration"]
		if d < 0:
			d = Time.get_ticks_msec() - stat["start_msec"]
		return d / 1000.0
	return -1.0

func get_state(level: int) -> StateType:
	return _state[level]

func set_state(level: int, new_value: StateType) -> void:
	if _state[level] == new_value:
		return

	var msec := Time.get_ticks_msec()

	# prev inner_state
	var stat: Dictionary = _state_stats[level].get(_state[level], {})
	if stat:
		stat["duration"] = msec - stat["start_msec"]
	_state_stats[level][_state[level]] = stat
	
	# new inner_state
	stat = _state_stats[level].get(new_value, {})
	stat["start_msec"] = msec
	stat["duration"] = -1
	_state_stats[level][new_value] = stat

	_state[level] = new_value
	restart_state(level)

var cycle_state: StateType:
	set(new_value):
		set_state(0, new_value)
	get():
		return get_state(0)

var inner_state: StateType:
	set(new_value):
		set_state(1, new_value)
	get():
		return get_state(1)

func restart_state(level: int):
	match level:
		0:
			match cycle_state:
				StateType.MOVE:
					start_move()
				_: # StateType.IDLE
					pass
		_: # 1
			match _state[level]:
				StateType.WALK:
					start_walk()
				StateType.STAND_UP:
					start_stand_up()
				StateType.STAND_IDLE:
					start_stand_idle()
				StateType.RELAX:
					start_relax()
				StateType.BACK_2_FRONT:
					start_back2front()
				_: # StateType.IDLE
					start_stand_pose()
			state_changed.emit()


func start_relax():
	for joint in _joints:
		joint.stop_target()


func start_stand_pose():
	hip_L.start_target_angle(0.0)
	thigh_L.start_target_angle(0.0)
	calf_L.start_target_angle(0.0)
	foot_L.start_target_angle(0.0)
	hip_R.start_target_angle(0.0)
	thigh_R.start_target_angle(0.0)
	calf_R.start_target_angle(0.0)
	foot_R.start_target_angle(0.0)

	spine3.start_target_angle(0.0)
	spine2.start_target_angle(0.0)
	spine1.start_target_angle(0.0)
	head.start_target_angle(0.0)
	shoulder_L.stop_target()
	uarm_L.stop_target()
	farm_L.stop_target()
	shoulder_R.stop_target()
	uarm_R.stop_target()
	farm_R.stop_target()



func start_move():
	inner_state = StateType.FALL
	while cycle_state == StateType.MOVE:
		if inner_state == StateType.FALL:
			var b := body_hip.global_basis
			print(b.z)
			if b.z.y < -Xts.SIN45:
				inner_state = StateType.BACK_2_FRONT
			elif b.z.y > Xts.SIN45:
				inner_state = StateType.STAND_UP
			else:
				inner_state = StateType.STAND_IDLE
			print("inner_state", inner_state, "  z ", b.z.y)
		await _tree.create_timer(1.0).timeout

func next_cycle_state():
	inner_state = StateType.FALL


#region BACK_2_FRONT

func check_front(min_up: float = Xts.SIN15) -> void:
	if body_hip.global_transform.basis.z.y > min_up:
		next_cycle_state()

func start_back2front():
	print("start_back2front")
	# while inner_state == StateType.BACK_2_FRONT:
	# 	check_front()
	# 	if inner_state != StateType.BACK_2_FRONT: return

	spine3.start_target_angle(0.0)
	spine1.start_target_angle(0.0)
	head.start_target_angle(0.0)

	uarm_L.target_angle_range = 1.0
	uarm_R.target_angle_range = 1.0
	farm_L.target_angle_range = 0.9
	farm_R.target_angle_range = 0.0
	shoulder_L.target_angle_range = 0.99
	shoulder_R.target_angle_range = 0.75
	foot_L.target_angle_range = 0.7
	foot_R.target_angle_range = 0.7

	hip_L.target_angle_range = 0.6
	thigh_L.target_angle_range = 1.0
	calf_L.target_angle_range = 0.0

	hip_R.target_angle_range = 0.8
	thigh_R.target_angle_range = 1.0
	calf_R.target_angle_range = 0.0

	spine2.target_angle_range = 0.0

	await _tree.create_timer(2.0).timeout
	thigh_L.target_angle_range = 0.0
	thigh_R.target_angle_range = 0.0
	calf_R.target_angle_range = 0.5
	

	await _tree.create_timer(2.0).timeout
	spine2.target_angle_range = 0.0
	shoulder_L.target_angle_range = 0.5
	calf_R.target_angle_range = 0.0

	await _tree.create_timer(2.0).timeout
	next_cycle_state()


#endregion


#region STAND_IDLE


func start_stand_idle():
	var thigh: MuscleJoint
	var calf: MuscleJoint
	var hip: MuscleJoint
	var foot: MuscleJoint
	var up := Vector3.UP
	var fall_threshold := 0.999



	spine3.target_angle_range = walk_param.get("stand_idle.spine3", 0.9)
	while inner_state == StateType.STAND_IDLE:
		check_fall(Xts.SIN45)
		if inner_state != StateType.STAND_IDLE: return

		var s1b := body_hip.global_basis
		var right := s1b.x
		var forward := up.cross(right).normalized()
		right = forward.cross(up)
		
		var up_dot := s1b.y.dot(up)
		# print(up_dot)
		if up_dot < fall_threshold:
			var right_dot := s1b.y.dot(right)
			if right_dot > 0.0:
				thigh = thigh_R
				calf = calf_R
				hip = hip_R
				foot = foot_R
				# spine1.target_angle_range = 0.5 - walk_param.get("stand_idle.spine1"]
			else:
				thigh = thigh_L
				calf = calf_L
				hip = hip_L
				foot = foot_L
				# spine1.target_angle_range = 0.5 + walk_param.get("stand_idle.spine1"]

			hip.target_angle_range = walk_param.get("stand_idle.bend_hip", 0.2)
			thigh.target_angle_range = walk_param.get("stand_idle.bend_thigh", 1.0)
			calf.target_angle_range = walk_param.get("stand_idle.bend_calf", 1.0)
			foot.target_angle_range = walk_param.get("stand_idle.bend_foot", 0.0)

			await _tree.create_timer(walk_param.get("stand_idle.unbend_delay", 0.3)).timeout
			check_fall(Xts.SIN45)
			if inner_state != StateType.STAND_IDLE: return

			hip.target_angle_range = walk_param.get("stand_idle.unbend_hip", 0.8)
			thigh.target_angle_range = walk_param.get("stand_idle.unbend_thigh", 1.0)
			calf.target_angle_range = walk_param.get("stand_idle.unbend_calf", 0.0)
			foot.target_angle_range = walk_param.get("stand_idle.unbend_foot", 0.4)

			if thigh == thigh_L:
				thigh = thigh_R
				calf = calf_R
				hip = hip_R
				foot = foot_R
			else:
				thigh = thigh_L
				calf = calf_L
				hip = hip_L
				foot = foot_L

			hip.target_angle_range = walk_param.get("stand_idle.bend_hip", 0.2)
			thigh.target_angle_range = walk_param.get("stand_idle.bend_thigh", 1.0)
			calf.target_angle_range = walk_param.get("stand_idle.bend_calf", 1.0)
			foot.target_angle_range = walk_param.get("stand_idle.bend_foot", 0.0)

			await _tree.create_timer(walk_param.get("stand_idle.step_delay", 0.7)).timeout
			check_fall(Xts.SIN45)
			if inner_state != StateType.STAND_IDLE: return

			var fwd_dot := s1b.y.dot(forward)

			hip.target_angle_range = 0.8 - fwd_dot * walk_param.get("stand_idle.step_hip", 1.0)
			thigh.target_angle_range = 1.0 - abs(right_dot) * walk_param.get("stand_idle.step_thigh", 0.9)
			calf.target_angle_range = -fwd_dot * walk_param.get("stand_idle.step_calf", 0.5)
			foot.target_angle_range = 0.4 + fwd_dot * walk_param.get("stand_idle.step_foot", 0.1)
			# spine1.target_angle_range = 0.5

		await _tree.create_timer(walk_param.get("stand_idle.bend_delay", 0.7)).timeout

	next_cycle_state()

#endregion


#region WALK

func start_walk():
	hip_L.start_target_angle(0.0)
	thigh_L.start_target_angle(0.0)
	calf_L.start_target_angle(0.0)
	hip_R.start_target_angle(0.0)
	thigh_R.start_target_angle(0.0)
	calf_R.start_target_angle(0.0)

	spine3.start_target_angle(0.0)
	spine2.start_target_angle(0.0)
	spine1.start_target_angle(0.0)
	head.start_target_angle(0.0)
	shoulder_L.stop_target()
	uarm_L.stop_target()
	farm_L.stop_target()
	shoulder_R.stop_target()
	uarm_R.stop_target()
	farm_R.stop_target()

	foot_L.target_angle_range = walk_param.get("walk.foot", 0.3)
	foot_R.target_angle_range = walk_param.get("walk.foot", 0.3)

	for q in 5000:
		check_fall()
		if inner_state != StateType.WALK: return
		hip_L.target_angle_range = walk_param.get("walk.hip_L", 0.05)
		calf_L.target_angle_range = walk_param.get("walk.calf_L", 0.5)
		hip_R.target_angle_range = walk_param.get("walk.hip_R", 0.95)
		calf_R.target_angle_range = walk_param.get("walk.calf_R", 0.0)
		await _tree.create_timer(1.0).timeout

		check_fall()
		if inner_state != StateType.WALK: return
		hip_L.target_angle_range = walk_param.get("walk.hip_R", 0.95)
		calf_L.target_angle_range = walk_param.get("walk.calf_R", 0.0)
		hip_R.target_angle_range = walk_param.get("walk.hip_L", 0.05)
		calf_R.target_angle_range = walk_param.get("walk.calf_L", 0.5)
		await _tree.create_timer(1.0).timeout

	next_cycle_state()

func check_fall(min_up: float = Xts.SIN15) -> void:
	if body_hip.global_transform.basis.y.y < min_up:
		next_cycle_state()

#endregion


#region STAND_UP

func start_stand_up():
	uarm_L.target_angle_range = 0.0
	uarm_R.target_angle_range = 0.0
	farm_L.target_angle_range = 0.9
	farm_R.target_angle_range = 0.9
	await _tree.create_timer(1.0).timeout

	spine2.start_target_angle(0.0)
	spine1.start_target_angle(0.0)
	head.start_target_angle(0.0)

	shoulder_L.target_angle_range = 0.2
	shoulder_R.target_angle_range = 0.2

	foot_L.target_angle_range = 0.0
	foot_R.target_angle_range = 0.0
	spine3.target_angle_range = 1.0

	hip_L.target_angle_range = 0.0
	thigh_L.start_target_angle(0.0)
	calf_L.target_angle_range = 1.0

	hip_R.target_angle_range = 0.0
	thigh_R.start_target_angle(0.0)
	calf_R.target_angle_range = 1.0

	uarm_L.target_angle_range = 0.99
	uarm_R.target_angle_range = 0.99
	farm_L.target_angle_range = 0.2
	farm_R.target_angle_range = 0.2
	await _tree.create_timer(1.0).timeout

	farm_L.target_angle_range = 0.99
	farm_R.target_angle_range = 0.99
	await _tree.create_timer(1.0).timeout


	for key in walk_param.keys():
		if key.begins_with("stand_up."):
			var obj = get(key.substr(9))
			if obj is MuscleJoint:
				obj.target_angle_range = walk_param[key]

	await _tree.create_timer(walk_param.get("stand_up.delay_finish", 3.0)).timeout

	start_stand_pose()

	if cycle_state == StateType.IDLE:
		for q in 5000:
			check_fall(Xts.SIN45)
			if inner_state != StateType.STAND_UP: return
			await _tree.create_timer(1.0).timeout

	next_cycle_state()



#endregion
