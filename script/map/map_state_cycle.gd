extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 5

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.FALL

func _get_cycle_state_type_override() -> MuscleSkeleton.CycleState:
	return MuscleSkeleton.CycleState.MOVE

func _check_skel_session_finished_override(skel: MuscleSkeleton) -> bool:
	return skel.cycle_state != _get_cycle_state_type_override()


func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	var rnd := func(c: float) -> float:
		return clampf(randf_range(c - 0.2, c + 0.2), 0.0, 1.0)

	skel.walk_param = {
		"walk.foot": randf_range(0.1, 0.5),
		"walk.hip_L": randf_range(0.01, 0.2),
		"walk.calf_L": randf_range(0.3, 0.7),
		"walk.hip_R": randf_range(0.85, 0.99),
		"walk.calf_R": randf_range(0.0, 0.2),

		"stand_up.delay_finish": randf_range(0.5, 1.5),
		"stand_up.spine3": 0.5, "stand_up.shoulder_L": 0.8, "stand_up.shoulder_R": 0.8,
		"stand_up.foot_L": 0.5, "stand_up.foot_R": 0.5, "stand_up.hip_L": randf_range(0.45, 0.55), "stand_up.hip_R": randf_range(0.45, 0.55),
		"stand_up.thigh_L": 1.0, "stand_up.thigh_R": 1.0, "stand_up.calf_L": randf_range(0.75, 0.85), "stand_up.calf_R": randf_range(0.75, 0.85),
		"stand_up.uarm_L": 1.0, "stand_up.uarm_R": 1.0, "stand_up.farm_L": 1.0, "stand_up.farm_R": 1.0,
	
		"stand_idle.spine3": rnd.call(0.9),

		"stand_idle.bend_delay": rnd.call(0.7),
		"stand_idle.bend_hip": rnd.call(0.2), "stand_idle.bend_thigh": rnd.call(1.0),
		"stand_idle.bend_calf": rnd.call(1.0), "stand_idle.bend_foot": rnd.call(0.0),

		"stand_idle.unbend_delay": rnd.call(0.3),
		"stand_idle.unbend_hip": rnd.call(0.8), "stand_idle.unbend_thigh": rnd.call(1.0),
		"stand_idle.unbend_calf": rnd.call(0.0), "stand_idle.unbend_foot": rnd.call(0.4),

		"stand_idle.step_delay": rnd.call(0.7),
		"stand_idle.step_hip": rnd.call(1.0), "stand_idle.step_thigh": rnd.call(0.9),
		"stand_idle.step_calf": rnd.call(0.5), "stand_idle.step_foot": rnd.call(0.1),
	}



func _get_is_session_finished_override(skel: MuscleSkeleton) -> bool:
	return skel.cycle_state != _get_cycle_state_type_override()

func _btn_start_action_override() -> void:
	# _play_reset()
	# _play_create_random_sessions()
	_play_best_sessions()
	# _play_generations()
