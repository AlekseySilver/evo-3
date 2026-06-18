extends MapBase

func _btn_start_action_override() -> void:
	# await _play_create_random_sessions()
	# await _play_fill_sessions_fitness()
	# await _play_generations()
	await _play_best_sessions()

func _play_best_sessions() -> void:
	DB._db.query("select id from session s where type_id = 1 order by fitness desc limit 5")
	var rows := DB._db.query_result
	for row in rows:
		# get params from DB
		var session_id: int = int(row["id"])
		$UI/SelectedNode.text = str(session_id)
		var select_condition: String = "session_id = %s" % [session_id]
		var array: Array = DB._db.select_rows("walk_param", select_condition, ["joint", "range"])
		# array.filter(func(p): return p.score > 20)

		if _skel:
			_skel.queue_free()
			_skel = null
		await _tree.create_timer(0.5).timeout
		_skel = instantiate_skel()
		await _tree.create_timer(0.5).timeout

		_skel.walk_param = {}
		for a in array:
			_skel.walk_param[a["joint"]] = a["range"]

		_skel.state = MuscleSkeleton.StateType.WALK
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if _skel.state != MuscleSkeleton.StateType.WALK or Input.is_key_pressed(KEY_N):
				break


func _play_generations() -> void:
	if _skel:
		_skel.queue_free()
		_skel = null

	for _i in range(5):
		var py := PythonRunner.new()
		py.fire("generation_create", [1])
		var res = await py.run_completed
		print(res)

		await _play_fill_sessions_fitness()


func _play_fill_sessions_fitness() -> void:
	if _skel:
		_skel.queue_free()
		_skel = null

	var grid := []
	for i in range(10):
		grid.append({ "offset": Vector3(i * 10.0 - 50.0, 0.0, 0.0), "session_id": 0, "skel": null })
	DB._db.query("select id from session s where fitness is null order by id")
	var rows := DB._db.query_result
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
		var array: Array = DB._db.select_rows("walk_param", select_condition, ["joint", "range"])
		# array.filter(func(p): return p.score > 20)

		if skel:
			skel.queue_free()
		await _tree.create_timer(0.5).timeout
		skel = instantiate_skel(grid_cell["offset"])
		grid_cell["skel"] = skel
		await _tree.create_timer(0.5).timeout

		skel.walk_param = {}
		for a in array:
			skel.walk_param[a["joint"]] = a["range"]

		var start_msec := Time.get_ticks_msec()
		var end_msec: Array[int]
		skel.state = MuscleSkeleton.StateType.WALK
		var trigger = func():
			end_msec.append(Time.get_ticks_msec())
		skel.state_changed.connect(trigger)
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if skel.state != MuscleSkeleton.StateType.WALK:
				break
		if len(end_msec) == 0:
			end_msec.append(Time.get_ticks_msec())
		skel.state_changed.disconnect(trigger)

		# save to DB
		var sigmoid_fitness := 1.0 / (1.0 + exp(-0.00001 * (end_msec[0] - start_msec)))
		DB.update_walk_session(session_id, sigmoid_fitness)
		grid_cell["session_id"] = 0



func _play_create_random_sessions() -> void:
	randomize()
	
	for i in range(99):
		if _skel:
			_skel.queue_free()
			_skel = null
		await _tree.create_timer(0.5).timeout
		_skel = instantiate_skel()
		await _tree.create_timer(0.5).timeout

		_skel.walk_param = {
					"foot": randf_range(0.1, 0.5),
					"hip_L": randf_range(0.01, 0.2),
					"calf_L": randf_range(0.3, 0.7),
					"hip_R": randf_range(0.85, 0.99),
					"calf_R": randf_range(0.0, 0.2)
				}

		var start_msec := Time.get_ticks_msec()
		var end_msec: Array[int]
		_skel.state = MuscleSkeleton.StateType.WALK
		var trigger = func():
			end_msec.append(Time.get_ticks_msec())
		_skel.state_changed.connect(trigger)
		for sec in range(60):
			await _tree.create_timer(1.0).timeout
			if _skel.state != MuscleSkeleton.StateType.WALK:
				break
		if len(end_msec) == 0:
			end_msec.append(Time.get_ticks_msec())
		_skel.state_changed.disconnect(trigger)

		# save to DB
		var sigmoid_fitness := 1.0 / (1.0 + exp(-0.00001 * (end_msec[0] - start_msec)))
		var param := _skel.walk_param.keys().map(func(key): return {"joint": key, "range": _skel.walk_param[key]})
		DB.save_walk_session(1, sigmoid_fitness, param)


