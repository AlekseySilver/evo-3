class_name MuscleSkeleton extends Node3D


var _joints: Array[MuscleJoint]



@onready var hip_L: MuscleJoint = $HJL_Hip_Hip
@onready var thigh_L: MuscleJoint = $HJL_Hip_Thigh
@onready var calf_L: MuscleJoint = $HJL_Thigh_Calf
@onready var foot_L: MuscleJoint = $HJL_Calf_Foot
@onready var hip_R: MuscleJoint = $HJR_Hip_Hip
@onready var thigh_R: MuscleJoint = $HJR_Hip_Thigh
@onready var calf_R: MuscleJoint = $HJR_Thigh_Calf
@onready var foot_R: MuscleJoint = $HJR_Calf_Foot



func _ready() -> void:
	# var add_joint := func(joint):
	# 	_joints.append(joint)
	# Xts.foreach_child($Skel, add_joint, false, "MuscleJoint")
	Xts.foreach_child(self, func(x): _joints.append(x), false, "HingeJoint3D")
	# print(len(_joints))
	# for joint in _joints:
	# 	print("@onready var calf_R: MuscleJoint = $", joint.name)



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



