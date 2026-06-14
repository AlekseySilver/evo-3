extends Node3D
class_name MapBase


@onready var _tree: SceneTree = get_tree()

@onready var _skel: MuscleSkeleton = null

var _selected_muscle: MuscleJoint = null


func _ready() -> void:
	_skel = instantiate_skel()

	# var py := PythonRunner.new()
	# py.fire("pytest01")
	# var res = await py.run_completed
	# print(res)


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		_tree.quit()

	if Input.is_key_pressed(KEY_F):
		PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 0.0)
	if Input.is_key_pressed(KEY_G):
		PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 9.8)


func _on_target_angle_v_slider_drag_ended(value: bool) -> void:
	if _selected_muscle:
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
	await _btn_start_action_override()
	$UI/BtnStart.disabled = false


func _btn_start_action_override() -> void:
	await _tree.create_timer(0.5).timeout



func instantiate_skel(offset: Vector3 = Vector3.ZERO) -> MuscleSkeleton:
	var point := $InstPoint
	var skel: MuscleSkeleton = load("res://scene/person/big_foot.tscn").instantiate()
	point.add_child(skel)
	skel.global_position = point.global_position + offset
	return skel




# func _enter_tree():
# 	if OS.has_feature("editor"):
# 		var time := Time.get_datetime_dict_from_system()
# 		var file_name := "movie_%04d-%02d-%02d_%02d-%02d-%02d.avi" % [
# 			time.year, time.month, time.day,
# 			time.hour, time.minute, time.second
# 		]
# 		var dir := "res://movies/"
# 		var full_path := dir + file_name
		
# 		if not DirAccess.dir_exists_absolute(dir):
# 			DirAccess.make_dir_absolute(dir)

# 		ProjectSettings.set_setting("editor/movie_writer/movie_file", full_path)

