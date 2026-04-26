extends Node3D


var _joints: Array[MuscleJoint]


func _ready() -> void:
	# var add_joint := func(joint):
	# 	_joints.append(joint)
	# Xts.foreach_child($Skel, add_joint, false, "MuscleJoint")
	Xts.foreach_child(self, func(x): _joints.append(x), false, "HingeJoint3D")
	# print(len(_joints))



func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		for j in _joints:
			print(j.name, " angle = ", j.get_current_angle_deg())
	if Input.is_key_pressed(KEY_Q):
		for j in _joints:
			j.start_target_angle(-45.0)
	if Input.is_key_pressed(KEY_W):
		for j in _joints:
			j.start_target_angle(0.0)
	if Input.is_key_pressed(KEY_E):
		for j in _joints:
			j.start_target_angle(45.0)
	if Input.is_key_pressed(KEY_R):
		for j in _joints:
			j.stop_target()



