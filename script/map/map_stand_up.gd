extends MapBase



func _btn_start_action_override() -> void:
	$UI/SelectedNode.text = "_play_stand_up"
	if _skel:
		_skel.queue_free()
		_skel = null
	await _tree.create_timer(0.5).timeout
	_skel = instantiate_skel()
	await _tree.create_timer(0.5).timeout

	_skel.walk_param = {}
	# for a in array:
	# 	_skel.walk_param[a["joint"]] = a["range"]

	_skel.state = MuscleSkeleton.StateType.STAND_UP
	for sec in range(60):
		await _tree.create_timer(1.0).timeout
		if _skel.state != MuscleSkeleton.StateType.STAND_UP or Input.is_key_pressed(KEY_N):
			break


