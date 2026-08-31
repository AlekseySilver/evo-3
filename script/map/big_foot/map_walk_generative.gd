extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 1

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.WALK

func _check_skel_session_finished_override(skel: MuscleSkeleton) -> bool:
	return skel.state != _get_state_type_override()

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	skel.walk_param = {
			"walk.foot": randf_range(0.1, 0.5),
			"walk.hip_L": randf_range(0.01, 0.2),
			"walk.calf_L": randf_range(0.3, 0.7),
			"walk.hip_R": randf_range(0.85, 0.99),
			"walk.calf_R": randf_range(0.0, 0.2)
		}



func _btn_start_action_override() -> void:
	# await _play_create_random_sessions()
	# await _play_fill_sessions_fitness()
	# await _play_generations()
	await _play_best_sessions()


