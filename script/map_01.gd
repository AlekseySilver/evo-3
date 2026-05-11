extends Node3D

@onready var _tree: SceneTree = get_tree()

@onready var _skel: MuscleSkeleton = null

var _selected_muscle: MuscleJoint = null


func _ready() -> void:
	instantiate_skel()


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		_tree.quit()

	# if Input.is_key_pressed(KEY_S):
	# 	if _skel:
	# 		_skel.state = MuscleSkeleton.StateType.WALK

	if Input.is_key_pressed(KEY_F):
		PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 0.0)
	if Input.is_key_pressed(KEY_G):
		PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 9.8)


func _on_target_angle_v_slider_drag_ended(value: bool) -> void:
	_selected_muscle.target_angle_range = $UI/TargetAngleVSlider.value / 100.0


func _on_camera_3d_grabber_target_changed(target: RigidBody3D) -> void:
	# print(target.name)
	_selected_muscle = null
	var find_joint := func(node: Node):
		if node.get_node(node.node_b) == target:
			_selected_muscle = node as MuscleJoint

	Xts.foreach_child(target.get_parent(), find_joint, false, "HingeJoint3D")
	if _selected_muscle:
		$UI/SelectedNode.text = _selected_muscle.name
		$UI/TargetAngleVSlider.value = _selected_muscle.target_angle_range * 100.0



# func find_joint(finded_joint: Array[HingeJoint3D], node_b: RigidBody3D) -> Callable:
# 	# print("find_joint")
# 	return func(node: Node):
# 		# print("node", node.node_b, " - ", node_b.get_path())
# 		if node.get_node(node.node_b) == node_b:
# 			finded_joint.append(node)
# 			return true
# 		return false


func _on_btn_start_pressed() -> void:
	$UI/BtnStart.disabled = true

	DB._db.query("select id
					from session s 
					order by fitness desc
					limit 5")
	var rows := DB._db.query_result
	for row in rows:
		# get params from DB
		var select_condition : String = "session_id = %s" % [row["id"]]
		var array : Array = DB._db.select_rows("walk_param", select_condition, ["joint", "range"])
		# array.filter(func(p): return p.score > 20)

		if _skel:
			_skel.queue_free()
		await _tree.create_timer(0.5).timeout
		instantiate_skel()
		await _tree.create_timer(0.5).timeout

		_skel.walk_param = {}
		for a in array:
			_skel.walk_param[a["joint"]] = a["range"]

		_skel.state = MuscleSkeleton.StateType.WALK
		await _skel.state_changed

	$UI/BtnStart.disabled = false


func _on_btn_start_pressed_1() -> void:
	$UI/BtnStart.disabled = true
	
	randomize()
	
	for i in range(99):
		if _skel:
			_skel.queue_free()
		await _tree.create_timer(0.5).timeout
		instantiate_skel()
		await _tree.create_timer(0.5).timeout

		_skel.walk_param = {
					"foot": randf_range(0.1, 0.5),
					"hip_L": randf_range(0.01, 0.2),
					"calf_L": randf_range(0.3, 0.7),
					"hip_R": randf_range(0.85, 0.99),
					"calf_R": randf_range(0.0, 0.2)
				}

		# TODO get params from DB

		var start_msec := Time.get_ticks_msec()
		_skel.state = MuscleSkeleton.StateType.WALK
		await _skel.state_changed
		
		# save to DB
		var sigmoid_fitness := 1.0 / (1.0 + exp(-0.00001 * (Time.get_ticks_msec() - start_msec)))
		var param := _skel.walk_param.keys().map(func(key): return {"joint": key, "range": _skel.walk_param[key]})
		DB.save_walk_session(sigmoid_fitness, param)

	$UI/BtnStart.disabled = false



func instantiate_skel() -> void:
	_skel = load("res://scene/person/big_foot.tscn").instantiate()
	$InstPoint.add_child.call_deferred(_skel)




func _enter_tree():
	if OS.has_feature("editor"):
		var time := Time.get_datetime_dict_from_system()
		var file_name := "movie_%04d-%02d-%02d_%02d-%02d-%02d.avi" % [
			time.year, time.month, time.day,
			time.hour, time.minute, time.second
		]
		var dir := "res://movies/"
		var full_path := dir + file_name
		
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.make_dir_absolute(dir)

		ProjectSettings.set_setting("editor/movie_writer/movie_file", full_path)



