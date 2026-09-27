extends MapBaseSingleParams

const SESSION_TIMEOUT = 60


func _get_session_type_id_override() -> int:
	return 6

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.FALL

func _get_cycle_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.MOVE

func _check_skel_session_finished_override(skel: MuscleSkeleton) -> bool:
	return skel.cycle_state != _get_cycle_state_type_override()

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	var rnd := func(c: float) -> float:
		return clampf(randf_range(c - 0.2, c + 0.2), 0.0, 1.0)

	skel.walk_param = {
		"walk.1.spine3": rnd.call(0.99),
		"walk.1.hip_L": rnd.call(0.0),
		"walk.1.hip_R": rnd.call(0.0),
		"walk.1.calf_L": rnd.call(0.99),
		"walk.1.calf_R": rnd.call(0.99),
		"walk.1.foot_L": rnd.call(0.0),
		"walk.1.foot_R": rnd.call(0.0),
		"walk.1.farm_L": rnd.call(0.99),
		"walk.1.farm_R": rnd.call(0.99),
		"walk.1.shoulder_L": rnd.call(0.25),
		"walk.1.shoulder_R": rnd.call(0.25),
		"walk.1.timeout": rnd.call(1.0),
		"walk.2.spine3": rnd.call(0.55),
		"walk.2.hip_L": rnd.call(0.3),
		"walk.2.hip_R": rnd.call(0.3),
		"walk.2.calf_L": rnd.call(0.75),
		"walk.2.calf_R": rnd.call(0.75),
		"walk.2.foot_L": rnd.call(0.15),
		"walk.2.foot_R": rnd.call(0.15),
		"walk.2.farm_L": rnd.call(0.99),
		"walk.2.farm_R": rnd.call(0.99),
		"walk.2.shoulder_L": rnd.call(0.1),
		"walk.2.shoulder_R": rnd.call(0.1),
	}



func _get_is_session_finished_override(skel: MuscleSkeleton) -> bool:
	# print("skelZ: ", skel.body_hip.global_position.z)
	return skel.cycle_state != _get_cycle_state_type_override() or skel.body_hip.global_position.z < -30.0

func _btn_start_action_override() -> void:
	# _play_reset()
	# _play_walk()
	_play_create_random_sessions(5, SESSION_TIMEOUT)
	# _play_best_sessions()
	# _play_generations()




func _play_walk() -> void:
	$UI/SelectedNode.text = "_play_walk"
	await _skel_reset(true)

	_skel.inner_state = _get_state_type_override()
	_skel.cycle_state = _get_cycle_state_type_override()


func _calc_fitness_override() -> float:
	return 1 - _skel.get_state_last_duration_second(0, _get_cycle_state_type_override()) / float(SESSION_TIMEOUT)
