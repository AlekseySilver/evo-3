extends MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return 2

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.STAND_UP

func _set_skel_random_params_override(skel: MuscleSkeleton) -> void:
	skel.walk_param = { "stand_up.delay_finish": randf_range(0.5, 1.5),
			"stand_up.spine3": 0.5, "stand_up.shoulder_L": 0.8, "stand_up.shoulder_R": 0.8,
			"stand_up.foot_L": 0.5, "stand_up.foot_R": 0.5, "stand_up.hip_L": randf_range(0.45, 0.55), "stand_up.hip_R": randf_range(0.45, 0.55),
			"stand_up.thigh_L": 1.0, "stand_up.thigh_R": 1.0, "stand_up.calf_L": randf_range(0.75, 0.85), "stand_up.calf_R": randf_range(0.75, 0.85),
			"stand_up.uarm_L": 1.0, "stand_up.uarm_R": 1.0, "stand_up.farm_L": 1.0, "stand_up.farm_R": 1.0,
			}




func _btn_start_action_override() -> void:
	# _play_reset()
	# _play_create_random_sessions()
	_play_best_sessions()
	# _play_generations()
