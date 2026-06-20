extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 1

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.WALK

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	skel.walk_param = {
			"foot": randf_range(0.1, 0.5),
			"hip_L": randf_range(0.01, 0.2),
			"calf_L": randf_range(0.3, 0.7),
			"hip_R": randf_range(0.85, 0.99),
			"calf_R": randf_range(0.0, 0.2)
		}

func _set_skel_params_from_array_override(skel: MuscleSkeleton, array: Array) -> void:
	skel.walk_param = {}
	for a in array:
		skel.walk_param[a["joint"]] = a["range"]

func _get_skel_params4db_override(skel: MuscleSkeleton) -> Array:
	return get_params4db(skel.walk_param)



func _btn_start_action_override() -> void:
	# await _play_create_random_sessions()
	# await _play_fill_sessions_fitness()
	# await _play_generations()
	await _play_best_sessions()


