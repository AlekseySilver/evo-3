extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 3

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.STAND_IDLE

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	skel.stand_idle_param = {
		"fall_threshold": randf_range(0.95, 0.999), "step_delay": randf_range(0.45, 0.55), "next_delay": randf_range(0.45, 0.55),
		"side_rate": randf_range(0.45, 0.95), "fwd_rate": randf_range(0.55, 0.95),
		"spine3": randf_range(0.85, 0.95), "spine1": randf_range(0.15, 0.25),
		"bend_hip": randf_range(0.15, 0.25), "bend_thigh": randf_range(0.45, 0.999),
		"bend_calf": randf_range(0.95, 0.999), "bend_foot": randf_range(0.0, 0.2), 
		"straight_calf": randf_range(0.45, 0.55), "straight_foot": randf_range(0.05, 0.15)
	}


func _set_skel_params_from_array_override(skel: MuscleSkeleton, array: Array) -> void:
	skel.stand_idle_param = {}
	for a in array:
		skel.stand_idle_param[a["joint"]] = a["range"]

func _get_skel_params4db_override(skel: MuscleSkeleton) -> Array:
	return get_params4db(skel.stand_idle_param)


func _btn_start_action_override() -> void:
	_play_reset()
	# _play_create_random_sessions(81)
	# _play_best_sessions()
	# _play_generations(10, true)
