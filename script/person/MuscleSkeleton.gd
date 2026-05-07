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

@onready var head: MuscleJoint = $HJ_Spine1_Head
@onready var shoulder_L: MuscleJoint = $HJL_Spine1_Shoulder
@onready var uarm_L: MuscleJoint = $HJL_Shoulder_UArm
@onready var farm_L: MuscleJoint = $HJL_UArm_FArm
@onready var shoulder_R: MuscleJoint = $HJR_Spine1_Shoulder
@onready var uarm_R: MuscleJoint = $HJR_Shoulder_UArm
@onready var farm_R: MuscleJoint = $HJR_UArm_FArm
@onready var spine1: MuscleJoint = $HJ_Hip_Spine1





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


func start_stand_pose():
	hip_L.start_target_angle(0.0)
	thigh_L.start_target_angle(0.0)
	calf_L.start_target_angle(0.0)
	foot_L.start_target_angle(0.0)
	hip_R.start_target_angle(0.0)
	thigh_R.start_target_angle(0.0)
	calf_R.start_target_angle(0.0)
	foot_R.start_target_angle(0.0)

