extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 3

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.STAND_IDLE

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	var rnd := func(c: float) -> float:
		return clampf(randf_range(c - 0.2, c + 0.2), 0.0, 1.0)

	skel.walk_param = {
		"stand_idle.spine3": rnd.call(0.9),

		"stand_idle.bend_delay": rnd.call(0.7),
		"stand_idle.bend_hip": rnd.call(0.2), "stand_idle.bend_thigh": rnd.call(1.0),
		"stand_idle.bend_calf": rnd.call(1.0), "stand_idle.bend_foot": rnd.call(0.0),

		"stand_idle.unbend_delay": rnd.call(0.3),
		"stand_idle.unbend_hip": rnd.call(0.8), "stand_idle.unbend_thigh": rnd.call(1.0),
		"stand_idle.unbend_calf": rnd.call(0.0), "stand_idle.unbend_foot": rnd.call(0.4),

		"stand_idle.step_delay": rnd.call(0.7),
		"stand_idle.step_hip": rnd.call(1.0), "stand_idle.step_thigh": rnd.call(0.9),
		"stand_idle.step_calf": rnd.call(0.5), "stand_idle.step_foot": rnd.call(0.1)
	}



func _btn_start_action_override() -> void:
	# _play_reset()
	# _play_create_random_sessions(200)
	_play_best_sessions()
	# _play_generations(10, true)
