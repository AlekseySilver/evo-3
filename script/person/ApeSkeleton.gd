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
		thigh_L.target_angle_range = 0.99
		calf_L.target_angle_range = 0.99

		hip_R.target_angle_range = 0.0
		thigh_R.target_angle_range = 0.99
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
		hip_L.target_angle_range = 0.0
		hip_R.target_angle_range = 0.0
		farm_L.target_angle_range = 0.99
		farm_R.target_angle_range = 0.99
		shoulder_L.target_angle_range = 0.25
		shoulder_R.target_angle_range = 0.25

	if Input.is_key_pressed(KEY_V):
		hip_L.target_angle_range = 0.3
		hip_R.target_angle_range = 0.3
		farm_L.target_angle_range = 0.99
		farm_R.target_angle_range = 0.99
		shoulder_L.target_angle_range = 0.15
		shoulder_R.target_angle_range = 0.15

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




#region BACK_2_FRONT  # TODO change



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
