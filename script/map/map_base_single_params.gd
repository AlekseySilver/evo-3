extends MapBase
class_name MapBaseSingleParams

func _get_session_type_id_override() -> int:
	return -1

func _get_state_type_override() -> MuscleSkeleton.StateType:
	return MuscleSkeleton.StateType.IDLE

func _get_cycle_state_type_override() -> MuscleSkeleton.CycleState:
	return MuscleSkeleton.CycleState.IDLE


func _set_skel_random_params_override(__skel: MuscleSkeleton) -> void:
	pass

func _set_skel_params_from_array_override(__skel: MuscleSkeleton, _array: Array) -> void:
	pass

func _get_skel_params4db_override(__skel: MuscleSkeleton) -> Array:
	return []

func _skel_reset(inst: bool = false) -> void:
	$Camera3D.target_path = NodePath()
	if _skel:
		_skel.queue_free()
		_skel = null
	if inst:
		await _tree.create_timer(0.5).timeout
		_skel = instantiate_skel()
		await _tree.create_timer(0.5).timeout
		$Camera3D.target_path = _skel.body_hip.get_path()


func _play_reset() -> void:
	$UI/SelectedNode.text = "_play_reset"
	await _skel_reset(true)

	# _skel.walk_param = {}
	# # for a in array:
	# # 	_skel.walk_param[a["joint"]] = a["range"]

	# _skel.state = _get_state_type_override()
	# for sec in range(60):
	# 	await _tree.create_timer(1.0).timeout
	# 	if _skel.state != _get_state_type_override() or Input.is_key_pressed(KEY_N):
	# 		break

func _play_best_sessions() -> void:
	var rows := await DB.query_async("select id, fitness from session s where type_id = {0} order by fitness desc limit 5".format([_get_session_type_id_override()]))
	for row in rows:
		# get params from DB
		var session_id: int = int(row["id"])
		$UI/SelectedNode.text = str(session_id)
		var select_condition: String = "session_id = %s" % [session_id]
		var array: Array = await DB.select_rows_async("walk_param", select_condition, ["joint", "range"])
		# array.filter(func(p): return p.score > 20)

		await _skel_reset(true)

		_set_skel_params_from_array_override(_skel, array)

		_skel.state = _get_state_type_override()
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if _skel.state != _get_state_type_override() or Input.is_key_pressed(KEY_N):
				break

		var sigmoid_fitness2 := calc_fitness2(_skel.get_state_last_duration_second(_get_state_type_override()))
		print(sigmoid_fitness2, row["fitness"])


func _play_generations(count: int = 1, generation_create: bool = false) -> void:
	await _skel_reset()

	for i in range(count):
		$UI/SelectedNode.text = str(i)
		if generation_create:
			$UI/SelectedNode.text += " generation_create"
			var py := PythonRunner.new()
			py.fire("generation_create", [_get_session_type_id_override()])
			var res = await py.run_completed
			print(res)
			

		await _play_fill_sessions_fitness()


func _play_fill_sessions_fitness(parallel_count: int = 10, space_between: float = 10.0) -> void:
	await _skel_reset()

	var offset := space_between * parallel_count * 0.5
	var grid := []
	for i in range(parallel_count):
		grid.append({ "offset": Vector3(i * space_between - offset, 0.0, 0.0), "session_id": 0, "skel": null })
	var rows := await DB.query_async("select id from session s where type_id = {0} and fitness is null order by id".format([_get_session_type_id_override()]))
	var row_id := 0
	var loop := true
	while loop:
		loop = false
		await _tree.create_timer(0.5).timeout
		$UI/SelectedNode.text = ""
		for grid_cell in grid:
			if grid_cell["session_id"] == 0:
				if row_id < len(rows):
					loop = true
					grid_cell["session_id"] = int(rows[row_id]["id"])
					row_id += 1
					# print(row_id)
					_play_fill_sessions_fitness_one(grid_cell)
			else:
				loop = true
				$UI/SelectedNode.text += ", " + str(grid_cell["session_id"])

	for grid_cell in grid:
		var skel = grid_cell["skel"]
		if skel:
			skel.queue_free()

func _play_fill_sessions_fitness_one(grid_cell: Dictionary) -> void:
	# get params from DB
	var session_id: int = grid_cell["session_id"]
	var skel: MuscleSkeleton = grid_cell["skel"]
	var select_condition: String = "session_id = %s" % [session_id]
	var array: Array = await DB.select_rows_async("walk_param", select_condition, ["joint", "range"])
	# array.filter(func(p): return p.score > 20)

	if skel:
		skel.queue_free()
	await _tree.create_timer(0.5).timeout
	skel = instantiate_skel(grid_cell["offset"])
	grid_cell["skel"] = skel
	await _tree.create_timer(0.5).timeout

	_set_skel_params_from_array_override(skel, array)

	skel.state = _get_state_type_override()
	for sec in range(60):
		await _tree.create_timer(1.0).timeout
		if skel.state != _get_state_type_override():
			break
	
	# save to DB
	var sigmoid_fitness := calc_fitness2(skel.get_state_last_duration_second(_get_state_type_override()))
	await DB.update_walk_session(session_id, sigmoid_fitness)
	grid_cell["session_id"] = 0


func _get_is_session_finished_override(skel: MuscleSkeleton) -> bool:
	return skel.state != _get_state_type_override()


func _play_create_random_sessions(count: int = 5) -> void:
	$UI/SelectedNode.text = "_play_create_random_sessions"
	randomize()

	for i in range(count):
		$UI/SelectedNode.text = str(i)
		await _skel_reset(true)

		_set_skel_random_params_override(_skel)

		_skel.state = _get_state_type_override()
		_skel.cycle_state = _get_cycle_state_type_override()
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if _get_is_session_finished_override(_skel):
				break

		# save to DB
		var sigmoid_fitness := calc_fitness2(_skel.get_state_last_duration_second(_get_state_type_override()))
		var param := _get_skel_params4db_override(_skel)
		await DB.save_walk_session(_get_session_type_id_override(), sigmoid_fitness, param)


