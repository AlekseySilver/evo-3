class_name MuscleSkeleton extends Node3D

enum StateType { IDLE, WALK, FALL, STAND_UP, STAND_IDLE, RELAX, BACK_2_FRONT }
enum CycleState { IDLE, MOVE }

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
var _state := StateType.IDLE
var _state_stats: Dictionary[StateType, Dictionary]

var _cycle_state := CycleState.IDLE

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
	restart_state()


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		for j in _joints:
			print(j.name, " angle = ", j.get_current_angle_deg())
	
	if Input.is_key_pressed(KEY_S):
		cycle_state = CycleState.MOVE
		print(cycle_state)

		# state = StateType.BACK_2_FRONT
		# print(state)


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



func get_state_last_duration_second(state_: StateType) -> float:
	var stat: Dictionary = _state_stats.get(state_)
	if stat:
		var d: int = stat["duration"]
		if d < 0:
			d = Time.get_ticks_msec() - stat["start_msec"]
		return d / 1000.0
	return -1.0

var cycle_state: CycleState:
	set(new_value):
		if _cycle_state == new_value:
			return
		_cycle_state = new_value
		restart_cycle_state()
	get():
		return _cycle_state

var state: StateType:
	set(new_value):
		if _state == new_value:
			return

		var msec := Time.get_ticks_msec()

		# prev state
		var stat: Dictionary = _state_stats.get(_state, {})
		if stat:
			stat["duration"] = msec - stat["start_msec"]
		_state_stats[_state] = stat
		
		# new state
		stat = _state_stats.get(new_value, {})
		stat["start_msec"] = msec
		stat["duration"] = -1
		_state_stats[new_value] = stat

		_state = new_value
		restart_state()
	get():
		return _state

func restart_state():
	match _state:
		StateType.WALK:
			start_stand_pose()
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


func restart_cycle_state():
	match _cycle_state:
		CycleState.MOVE:
			start_move()
		_: # CycleState.IDLE
			pass

func start_move():
	state = StateType.FALL
	while cycle_state == CycleState.MOVE:
		if state == StateType.FALL:
			var b := body_hip.global_basis
			print(b.z)
			if b.z.y < -Xts.SIN45:
				state = StateType.BACK_2_FRONT
			elif b.z.y > Xts.SIN45:
				state = StateType.STAND_UP
			else:
				state = StateType.STAND_IDLE
			print("state", state)
		await _tree.create_timer(1.0).timeout

func next_cycle_state():
	state = StateType.FALL


#region BACK_2_FRONT

func check_front(min_up: float = Xts.SIN15) -> void:
	if body_hip.global_transform.basis.z.y > min_up:
		next_cycle_state()

func start_back2front():
	print("start_back2front")
	# while state == StateType.BACK_2_FRONT:
	# 	check_front()
	# 	if state != StateType.BACK_2_FRONT: return

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



	spine3.target_angle_range = walk_param.get("spine3", 0.9)
	while state == StateType.STAND_IDLE:
		check_fall(Xts.SIN45)
		if state != StateType.STAND_IDLE: return

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
				# spine1.target_angle_range = 0.5 - walk_param.get("spine1"]
			else:
				thigh = thigh_L
				calf = calf_L
				hip = hip_L
				foot = foot_L
				# spine1.target_angle_range = 0.5 + walk_param.get("spine1"]

			hip.target_angle_range = walk_param.get("bend_hip", 0.2)
			thigh.target_angle_range = walk_param.get("bend_thigh", 1.0)
			calf.target_angle_range = walk_param.get("bend_calf", 1.0)
			foot.target_angle_range = walk_param.get("bend_foot", 0.0)

			await _tree.create_timer(walk_param.get("unbend_delay", 0.3)).timeout
			check_fall(Xts.SIN45)
			if state != StateType.STAND_IDLE: return

			hip.target_angle_range = walk_param.get("unbend_hip", 0.8)
			thigh.target_angle_range = walk_param.get("unbend_thigh", 1.0)
			calf.target_angle_range = walk_param.get("unbend_calf", 0.0)
			foot.target_angle_range = walk_param.get("unbend_foot", 0.4)

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

			hip.target_angle_range = walk_param.get("bend_hip", 0.2)
			thigh.target_angle_range = walk_param.get("bend_thigh", 1.0)
			calf.target_angle_range = walk_param.get("bend_calf", 1.0)
			foot.target_angle_range = walk_param.get("bend_foot", 0.0)

			await _tree.create_timer(walk_param.get("step_delay", 0.7)).timeout
			check_fall(Xts.SIN45)
			if state != StateType.STAND_IDLE: return

			var fwd_dot := s1b.y.dot(forward)

			hip.target_angle_range = 0.8 - fwd_dot * walk_param.get("step_hip", 1.0)
			thigh.target_angle_range = 1.0 - abs(right_dot) * walk_param.get("step_thigh", 0.9)
			calf.target_angle_range = -fwd_dot * walk_param.get("step_calf", 0.5)
			foot.target_angle_range = 0.4 + fwd_dot * walk_param.get("step_foot", 0.1)
			# spine1.target_angle_range = 0.5

		await _tree.create_timer(walk_param.get("bend_delay", 0.7)).timeout

	next_cycle_state()

#endregion


#region WALK

func start_walk():
	foot_L.target_angle_range = walk_param.get("foot", 0.3)
	foot_R.target_angle_range = walk_param.get("foot", 0.3)

	for q in 5000:
		check_fall()
		if state != StateType.WALK: return
		hip_L.target_angle_range = walk_param.get("hip_L", 0.05)
		calf_L.target_angle_range = walk_param.get("calf_L", 0.5)
		hip_R.target_angle_range = walk_param.get("hip_R", 0.95)
		calf_R.target_angle_range = walk_param.get("calf_R", 0.0)
		await _tree.create_timer(1.0).timeout

		check_fall()
		if state != StateType.WALK: return
		hip_L.target_angle_range = walk_param.get("hip_R", 0.95)
		calf_L.target_angle_range = walk_param.get("calf_R", 0.0)
		hip_R.target_angle_range = walk_param.get("hip_L", 0.05)
		calf_R.target_angle_range = walk_param.get("calf_L", 0.5)
		await _tree.create_timer(1.0).timeout

	next_cycle_state()

func check_fall(min_up: float = Xts.SIN15) -> void:
	if body_hip.global_transform.basis.y.y < min_up:
		next_cycle_state()

#endregion


#region STAND_UP

var stand_up_param := { "delay_finish": 3.0, "spine3": 0.0, "shoulder_L": 0.0, "shoulder_R": 0.0, "foot_L": 0.0, "foot_R": 0.0, "hip_L": 0.0, "hip_R": 0.0
				, "thigh_L": 0.0, "thigh_R": 0.0, "calf_L": 0.0, "calf_R": 0.0, "uarm_L": 0.0, "uarm_R": 0.0, "farm_L": 0.0, "farm_R": 0.0 }

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
		var obj = get(key)
		if obj is MuscleJoint:
			obj.target_angle_range = walk_param[key]

	await _tree.create_timer(walk_param.get("delay_finish", 3.0)).timeout

	start_stand_pose()

	for q in 5000:
		check_fall(Xts.SIN45)
		if state != StateType.STAND_UP: return
		await _tree.create_timer(1.0).timeout

	next_cycle_state()



#endregion
