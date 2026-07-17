extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 4

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.BACK_2_FRONT

func _set_skel_random_params_override(__skel: MuscleSkeleton) -> void:
	pass



func _btn_start_action_override() -> void:
	_play_reset()
	# _play_create_random_sessions()
	# _play_best_sessions()
	# _play_generations()
