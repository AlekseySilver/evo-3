class_name MuscleSkeleton extends Node3D

enum StateType { IDLE, WALK, FALL, STAND_UP }


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

@onready var body_hip: RigidBody3D = $Hip


@onready var _tree: SceneTree = get_tree()
var _state := StateType.IDLE
var _state_start_msec := Time.get_ticks_msec()

signal state_changed()

func _ready() -> void:
	PhysicsServer3D.body_add_collision_exception($Head.get_rid(), $Shoulder_L.get_rid())
	PhysicsServer3D.body_add_collision_exception($Head.get_rid(), $Shoulder_R.get_rid())
	PhysicsServer3D.body_add_collision_exception($Shoulder_L.get_rid(), $Shoulder_R.get_rid())


	# var add_joint := func(joint):
	# 	_joints.append(joint)
	# Xts.foreach_child($Skel, add_joint, false, "MuscleJoint")
	Xts.foreach_child(self, func(x): _joints.append(x), false, "HingeJoint3D")
	# print(len(_joints))
	# for joint in _joints:
	# 	print("@onready var calf_R: MuscleJoint = $", joint.name)
	restart_state()


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




var state: StateType:
	set(new_value):
		if _state == new_value:
			return
		_state = new_value
		restart_state()
	get():
		return _state

func restart_state():
	_state_start_msec = Time.get_ticks_msec()
	match _state:
		StateType.WALK:
			start_stand_pose()
			start_walk()
		StateType.STAND_UP:
			start_stand_up()
			start_stand_pose()
		_: # StateType.IDLE
			start_stand_pose()
	state_changed.emit()

func get_state_msec() -> int:
	return Time.get_ticks_msec() - _state_start_msec


func start_stand_pose():
	hip_L.start_target_angle(0.0)
	thigh_L.start_target_angle(0.0)
	calf_L.start_target_angle(0.0)
	foot_L.start_target_angle(0.0)
	hip_R.start_target_angle(0.0)
	thigh_R.start_target_angle(0.0)
	calf_R.start_target_angle(0.0)
	foot_R.start_target_angle(0.0)

	spine1.start_target_angle(0.0)
	head.start_target_angle(0.0)
	shoulder_L.stop_target()
	uarm_L.stop_target()
	farm_L.stop_target()
	shoulder_R.stop_target()
	uarm_R.stop_target()
	farm_R.stop_target()


#region WALK

var walk_param := { "foot": 0.3, "hip_L": 0.05, "calf_L": 0.5, "hip_R": 0.95, "calf_R": 0.0 }
func start_walk():
	foot_L.target_angle_range = walk_param["foot"]
	foot_R.target_angle_range = walk_param["foot"]

	for q in 5000:
		check_fall()
		if state != StateType.WALK: return
		hip_L.target_angle_range = walk_param["hip_L"]
		calf_L.target_angle_range = walk_param["calf_L"]
		hip_R.target_angle_range = walk_param["hip_R"]
		calf_R.target_angle_range = walk_param["calf_R"]
		await _tree.create_timer(1.0).timeout

		check_fall()
		if state != StateType.WALK: return
		hip_L.target_angle_range = walk_param["hip_R"]
		calf_L.target_angle_range = walk_param["calf_R"]
		hip_R.target_angle_range = walk_param["hip_L"]
		calf_R.target_angle_range = walk_param["calf_L"]
		await _tree.create_timer(1.0).timeout

	state = StateType.FALL

func check_fall() -> void:
	if body_hip.global_transform.basis.y.dot(Vector3.UP) < Xts.SIN15:
		state = StateType.FALL

#endregion


#region STAND_UP

func start_stand_up():
	foot_L.target_angle_range = walk_param["foot"]
	foot_R.target_angle_range = walk_param["foot"]

	for q in 5000:
		# check_stand()
		if state != StateType.STAND_UP: return
		hip_L.target_angle_range = walk_param["hip_L"]
		calf_L.target_angle_range = walk_param["calf_L"]
		hip_R.target_angle_range = walk_param["hip_R"]
		calf_R.target_angle_range = walk_param["calf_R"]
		await _tree.create_timer(1.0).timeout



	state = StateType.FALL



#endregion

