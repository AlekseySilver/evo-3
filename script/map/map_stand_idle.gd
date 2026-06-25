extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 3

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.STAND_IDLE

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	var rnd := func(c: float) -> float:
		return clampf(randf_range(c - 0.2, c + 0.2), 0.0, 1.0)

	skel.stand_idle_param = {
		"spine3": rnd.call(0.9),
		"bend_delay": rnd.call(0.7), "bend_hip": rnd.call(0.2), "bend_thigh": rnd.call(1.0), "bend_calf": rnd.call(1.0), "bend_foot": rnd.call(0.0),
		"unbend_delay": rnd.call(0.3), "unbend_hip": rnd.call(0.8), "unbend_thigh": rnd.call(1.0), "unbend_calf": rnd.call(0.0), "unbend_foot": rnd.call(0.4),
		"step_delay": rnd.call(0.7), "step_hip": rnd.call(1.0), "step_thigh": rnd.call(0.9), "step_calf": rnd.call(0.5), "step_foot": rnd.call(0.1)
	}



func _set_skel_params_from_array_override(skel: MuscleSkeleton, array: Array) -> void:
	skel.stand_idle_param = {}
	for a in array:
		skel.stand_idle_param[a["joint"]] = a["range"]

func _get_skel_params4db_override(skel: MuscleSkeleton) -> Array:
	return get_params4db(skel.stand_idle_param)


func _btn_start_action_override() -> void:
	# _play_reset()
	# _play_create_random_sessions(200)
	_play_best_sessions()
	# _play_generations(10, true)
