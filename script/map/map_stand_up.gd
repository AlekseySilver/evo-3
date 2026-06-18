extends MapBase



func _btn_start_action_override() -> void:
	_play_stand_up()
	# _play_create_random_sessions()
	# _play_best_sessions(2)
	# _play_generations(2)

func _play_stand_up() -> void:
	$UI/SelectedNode.text = "_play_stand_up"
	if _skel:
		_skel.queue_free()
		_skel = null
	await _tree.create_timer(0.5).timeout
	_skel = instantiate_skel()
	await _tree.create_timer(0.5).timeout

	# _skel.walk_param = {}
	# # for a in array:
	# # 	_skel.walk_param[a["joint"]] = a["range"]

	# _skel.state = MuscleSkeleton.StateType.STAND_UP
	# for sec in range(60):
	# 	await _tree.create_timer(1.0).timeout
	# 	if _skel.state != MuscleSkeleton.StateType.STAND_UP or Input.is_key_pressed(KEY_N):
	# 		break

func _play_best_sessions(type_id: int) -> void:
	var rows := await DB.query_async("select id from session s where type_id = {0} order by fitness desc limit 5".format([type_id]))
	for row in rows:
		# get params from DB
		var session_id: int = int(row["id"])
		$UI/SelectedNode.text = str(session_id)
		var select_condition: String = "session_id = %s" % [session_id]
		var array: Array = await DB.select_rows_async("walk_param", select_condition, ["joint", "range"])
		# array.filter(func(p): return p.score > 20)

		if _skel:
			_skel.queue_free()
			_skel = null
		await _tree.create_timer(0.5).timeout
		_skel = instantiate_skel()
		await _tree.create_timer(0.5).timeout

		_skel.stand_up_param = {}
		for a in array:
			_skel.stand_up_param[a["joint"]] = a["range"]

		_skel.state = MuscleSkeleton.StateType.STAND_UP
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if _skel.state != MuscleSkeleton.StateType.STAND_UP or Input.is_key_pressed(KEY_N):
				break



func _play_generations(type_id: int) -> void:
	if _skel:
		_skel.queue_free()
		_skel = null

	for _i in range(1):
		# var py := PythonRunner.new()
		# py.fire("generation_create", [type_id])
		# var res = await py.run_completed
		# print(res)

		await _play_fill_sessions_fitness(type_id)


func _play_fill_sessions_fitness(type_id: int) -> void:
	if _skel:
		_skel.queue_free()
		_skel = null

	var grid := []
	for i in range(10):
		grid.append({ "offset": Vector3(i * 10.0 - 50.0, 0.0, 0.0), "session_id": 0, "skel": null })
	var rows := await DB.query_async("select id from session s where type_id = {0} and fitness is null order by id".format([type_id]))
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
		print("q1")
		var array: Array = await DB.select_rows_async("walk_param", select_condition, ["joint", "range"])
		print("q2")
		# array.filter(func(p): return p.score > 20)

		if skel:
			skel.queue_free()
		await _tree.create_timer(0.5).timeout
		skel = instantiate_skel(grid_cell["offset"])
		grid_cell["skel"] = skel
		await _tree.create_timer(0.5).timeout

		skel.stand_up_param = {}
		for a in array:
			skel.stand_up_param[a["joint"]] = a["range"]

		var start_msec := Time.get_ticks_msec()
		var end_msec: Array[int]
		skel.state = MuscleSkeleton.StateType.STAND_UP
		var trigger = func():
			end_msec.append(Time.get_ticks_msec())
		skel.state_changed.connect(trigger)
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if skel.state != MuscleSkeleton.StateType.STAND_UP:
				break
		if len(end_msec) == 0:
			end_msec.append(Time.get_ticks_msec())
		skel.state_changed.disconnect(trigger)

		# save to DB
		var sigmoid_fitness := 1.0 / (1.0 + exp(-0.00001 * (end_msec[0] - start_msec)))
		await DB.update_walk_session(session_id, sigmoid_fitness)
		grid_cell["session_id"] = 0




func _play_create_random_sessions() -> void:
	$UI/SelectedNode.text = "_play_create_random_sessions"
	randomize()

	for i in range(50):
		$UI/SelectedNode.text = str(i)
		if _skel:
			_skel.queue_free()
			_skel = null
		await _tree.create_timer(0.5).timeout
		_skel = instantiate_skel()
		await _tree.create_timer(0.5).timeout

		_skel.stand_up_param = { "delay_finish": randf_range(1.0, 3.0), "spine3": randf_range(0.0, 1.0), "shoulder_L": 0.5, "shoulder_R": 0.5
			, "foot_L": 0.5, "foot_R": 0.5, "hip_L": randf_range(0.0, 1.0), "hip_R": randf_range(0.0, 1.0)
			, "thigh_L": randf_range(0.0, 1.0), "thigh_R": randf_range(0.0, 1.0), "calf_L": randf_range(0.0, 1.0), "calf_R": randf_range(0.0, 1.0)
			, "uarm_L": randf_range(0.0, 1.0), "uarm_R": randf_range(0.0, 1.0), "farm_L": randf_range(0.0, 1.0), "farm_R": randf_range(0.0, 1.0) }

		var start_msec := Time.get_ticks_msec()
		var end_msec: Array[int]
		_skel.state = MuscleSkeleton.StateType.STAND_UP
		var trigger = func():
			end_msec.append(Time.get_ticks_msec())
		_skel.state_changed.connect(trigger)
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if _skel.state != MuscleSkeleton.StateType.STAND_UP:
				break
		if len(end_msec) == 0:
			end_msec.append(Time.get_ticks_msec())
		_skel.state_changed.disconnect(trigger)

		# save to DB
		var sigmoid_fitness := 1.0 / (1.0 + exp(-0.00001 * (end_msec[0] - start_msec)))
		var param := _skel.stand_up_param.keys().map(func(key): return {"joint": key, "range": _skel.stand_up_param[key]})
		await DB.save_walk_session(2, sigmoid_fitness, param)
