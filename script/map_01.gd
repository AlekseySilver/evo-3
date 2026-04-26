extends Node3D

@onready var _tree: SceneTree = get_tree()

func _ready() -> void:
	# print(Vector3.FORWARD)
	pass


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		_tree.quit()



func start_walk():
	await _tree.create_timer(1.0).timeout
