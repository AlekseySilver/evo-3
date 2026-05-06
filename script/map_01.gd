extends Node3D

@onready var _tree: SceneTree = get_tree()

@onready var _skel: MuscleSkeleton = $Skel

var _selected_muscle: MuscleJoint = null

var _is_walking := false


func _ready() -> void:
	for j in _skel._joints:
		j.start_target_angle(0.0)


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		_tree.quit()

	if Input.is_key_pressed(KEY_S):
		start_walk()

	if Input.is_key_pressed(KEY_F):
		PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 0.0)
	if Input.is_key_pressed(KEY_G):
		PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 9.8)






func start_walk():
	if _is_walking:
			return
	_is_walking = true
	
	for q in 5:
		_skel.hip_L.target_angle_range = 0.05
		_skel.calf_L.target_angle_range = 0.5
		_skel.hip_R.target_angle_range = 0.95
		_skel.calf_R.target_angle_range = 0.0
		await _tree.create_timer(1.0).timeout

		_skel.hip_L.target_angle_range = 0.95
		_skel.calf_L.target_angle_range = 0.0
		_skel.hip_R.target_angle_range = 0.05
		_skel.calf_R.target_angle_range = 0.5
		await _tree.create_timer(1.0).timeout


	_is_walking = false




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
