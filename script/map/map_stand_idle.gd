extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 3

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.STAND_IDLE

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	skel.stand_up_param = { "delay_finish": randf_range(0.5, 1.5), "spine3": 0.5, "shoulder_L": 0.8, "shoulder_R": 0.8
			, "foot_L": 0.5, "foot_R": 0.5, "hip_L": randf_range(0.45, 0.55), "hip_R": randf_range(0.45, 0.55)
			, "thigh_L": 1.0, "thigh_R": 1.0, "calf_L": randf_range(0.75, 0.85), "calf_R": randf_range(0.75, 0.85)
			, "uarm_L": 1.0, "uarm_R": 1.0, "farm_L": 1.0, "farm_R": 1.0 }

func _set_skel_params_from_array_override(skel: MuscleSkeleton, array: Array) -> void:
	skel.stand_up_param = {}
	for a in array:
		skel.stand_up_param[a["joint"]] = a["range"]

func _get_skel_params4db_override(skel: MuscleSkeleton) -> Array:
	return get_params4db(skel.stand_up_param)


func _btn_start_action_override() -> void:
	_play_reset()
	# _play_create_random_sessions()
	# _play_best_sessions()
	# _play_generations()
