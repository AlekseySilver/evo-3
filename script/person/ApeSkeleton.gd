class_name ApeSkeleton extends MuscleSkeleton


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		for j in _joints:
			print(j.name, " angle = ", j.get_current_angle_deg())
	
	if Input.is_key_pressed(KEY_S):
		spine3.target_angle_range = 0.99
		spine2.target_angle_range = 0.5
		spine1.target_angle_range = 0.5
		# head.start_target_angle(0.0)

		uarm_L.target_angle_range = 1.0
		uarm_R.target_angle_range = 1.0
		farm_L.target_angle_range = 0.0
		farm_R.target_angle_range = 0.0
		shoulder_L.target_angle_range = 0.99
		shoulder_R.target_angle_range = 0.99

		foot_L.target_angle_range = 0.0
		foot_R.target_angle_range = 0.0

		hip_L.target_angle_range = 0.0
		hip_R.target_angle_range = 0.0
		thigh_L.target_angle_range = 0.99
		thigh_R.target_angle_range = 0.99
		calf_L.target_angle_range = 0.99
		calf_R.target_angle_range = 0.99

	if Input.is_key_pressed(KEY_Z):
		farm_L.target_angle_range = 0.99
		farm_R.target_angle_range = 0.99
		shoulder_L.target_angle_range = 0.5
		shoulder_R.target_angle_range = 0.5

	if Input.is_key_pressed(KEY_X):
		farm_L.target_angle_range = 0.99
		farm_R.target_angle_range = 0.99
		shoulder_L.target_angle_range = 0.15
		shoulder_R.target_angle_range = 0.15

	if Input.is_key_pressed(KEY_C):
		spine3.target_angle_range = 0.99
		hip_L.target_angle_range = 0.0
		hip_R.target_angle_range = 0.0
		calf_L.target_angle_range = 0.99
		calf_R.target_angle_range = 0.99
		foot_L.target_angle_range = 0.0
		foot_R.target_angle_range = 0.0

		farm_L.target_angle_range = 0.99
		farm_R.target_angle_range = 0.99
		shoulder_L.target_angle_range = 0.25
		shoulder_R.target_angle_range = 0.25

	if Input.is_key_pressed(KEY_V):
		spine3.target_angle_range = 0.55
		hip_L.target_angle_range = 0.3
		hip_R.target_angle_range = 0.3
		calf_L.target_angle_range = 0.75
		calf_R.target_angle_range = 0.75
		foot_L.target_angle_range = 0.15
		foot_R.target_angle_range = 0.15

		farm_L.target_angle_range = 0.99
		farm_R.target_angle_range = 0.99
		shoulder_L.target_angle_range = 0.1
		shoulder_R.target_angle_range = 0.1

	if Input.is_key_pressed(KEY_B):
		spine3.target_angle_range = 0.5
		farm_L.target_angle_range = 0.99
		farm_R.target_angle_range = 0.99
		shoulder_L.target_angle_range = 0.55
		shoulder_R.target_angle_range = 0.55

		# await _tree.create_timer(2.0).timeout
		# thigh_L.target_angle_range = 0.0
		# thigh_R.target_angle_range = 0.0

		# await _tree.create_timer(2.0).timeout
		# shoulder_L.target_angle_range = 0.5
		# spine2.target_angle_range = 0.5


func start_stand_pose():
	spine3.target_angle_range = 0.99
	spine2.target_angle_range = 0.5
	spine1.target_angle_range = 0.5
	hip_L.target_angle_range = 0.0
	hip_R.target_angle_range = 0.0
	thigh_L.target_angle_range = 0.99
	thigh_R.target_angle_range = 0.99
	calf_L.target_angle_range = 0.99
	calf_R.target_angle_range = 0.99
	foot_L.target_angle_range = 0.0
	foot_R.target_angle_range = 0.0
	shoulder_L.target_angle_range = 0.15
	shoulder_R.target_angle_range = 0.15
	uarm_L.target_angle_range = 1.0
	uarm_R.target_angle_range = 1.0
	farm_L.target_angle_range = 0.99
	farm_R.target_angle_range = 0.99


func start_move():
	inner_state = StateType.FALL
	while cycle_state == StateType.MOVE:
		if inner_state == StateType.FALL:
			var b := body_hip.global_basis
			# print(b.z)
			if b.z.y < 0.0:
				inner_state = StateType.BACK_2_FRONT
			else:
				inner_state = StateType.WALK
			print("inner_state", inner_state, "  z ", b.z.y)
		await _tree.create_timer(1.0).timeout





#region BACK_2_FRONT

func check_front(min_up: float = Xts.SIN15) -> void:
	if body_hip.global_transform.basis.z.y > min_up:
		next_cycle_state()

func start_back2front():
	print("start_back2front")
	# while state == StateType.BACK_2_FRONT:
	# 	check_front()
	# 	if state != StateType.BACK_2_FRONT: return

	spine3.target_angle_range = 0.99
	spine2.target_angle_range = 0.5
	spine1.target_angle_range = 0.5

	uarm_L.target_angle_range = 1.0
	uarm_R.target_angle_range = 1.0
	farm_L.target_angle_range = 0.0
	farm_R.target_angle_range = 0.0
	shoulder_L.target_angle_range = 0.99
	shoulder_R.target_angle_range = 0.99

	foot_L.target_angle_range = 0.0
	foot_R.target_angle_range = 0.0

	hip_L.target_angle_range = 0.0
	hip_R.target_angle_range = 0.0
	thigh_L.target_angle_range = 0.99
	thigh_R.target_angle_range = 0.99
	calf_L.target_angle_range = 0.99
	calf_R.target_angle_range = 0.99

	await _tree.create_timer(2.0).timeout
	farm_L.target_angle_range = 0.99
	farm_R.target_angle_range = 0.99
	shoulder_L.target_angle_range = 0.15
	shoulder_R.target_angle_range = 0.15


	await _tree.create_timer(2.0).timeout
	next_cycle_state()


#endregion



#region WALK

func start_walk():
	spine2.target_angle_range = 0.5
	spine1.target_angle_range = 0.5
	uarm_L.target_angle_range = 1.0
	uarm_R.target_angle_range = 1.0
	thigh_L.target_angle_range = 0.99
	thigh_R.target_angle_range = 0.99

	for q in 5000:
		check_fall()
		if inner_state != StateType.WALK: return
		spine3.target_angle_range = walk_param.get("walk.1.spine3", 0.99)
		hip_L.target_angle_range = walk_param.get("walk.1.hip_L", 0.0)
		hip_R.target_angle_range = walk_param.get("walk.1.hip_R", 0.0)
		calf_L.target_angle_range = walk_param.get("walk.1.calf_L", 0.99)
		calf_R.target_angle_range = walk_param.get("walk.1.calf_R", 0.99)
		foot_L.target_angle_range = walk_param.get("walk.1.foot_L", 0.0)
		foot_R.target_angle_range = walk_param.get("walk.1.foot_R", 0.0)

		farm_L.target_angle_range = walk_param.get("walk.1.farm_L", 0.99)
		farm_R.target_angle_range = walk_param.get("walk.1.farm_R", 0.99)
		shoulder_L.target_angle_range = walk_param.get("walk.1.shoulder_L", 0.25)
		shoulder_R.target_angle_range = walk_param.get("walk.1.shoulder_R", 0.25)
		await _tree.create_timer(walk_param.get("walk.1.timeout", 1.0)).timeout

		check_fall()
		if inner_state != StateType.WALK: return
		spine3.target_angle_range = walk_param.get("walk.2.spine3", 0.55)
		hip_L.target_angle_range = walk_param.get("walk.2.hip_L", 0.3)
		hip_R.target_angle_range = walk_param.get("walk.2.hip_R", 0.3)
		calf_L.target_angle_range = walk_param.get("walk.2.calf_L", 0.75)
		calf_R.target_angle_range = walk_param.get("walk.2.calf_R", 0.75)
		foot_L.target_angle_range = walk_param.get("walk.2.foot_L", 0.15)
		foot_R.target_angle_range = walk_param.get("walk.2.foot_R", 0.15)

		farm_L.target_angle_range = walk_param.get("walk.2.farm_L", 0.99)
		farm_R.target_angle_range = walk_param.get("walk.2.farm_R", 0.99)
		shoulder_L.target_angle_range = walk_param.get("walk.2.shoulder_L", 0.1)
		shoulder_R.target_angle_range = walk_param.get("walk.2.shoulder_R", 0.1)

		await _tree.create_timer(walk_param.get("walk.2.timeout", 1.0)).timeout

	next_cycle_state()

func check_fall(min_up: float = Xts.SIN15) -> void:
	if body_hip.global_transform.basis.z.y < min_up:
		next_cycle_state()

#endregion
