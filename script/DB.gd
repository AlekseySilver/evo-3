extends Node

var _db : SQLite = null
var db_name := "res://data/train.db"

var _do_async := false

func _ready() -> void:
	if OS.get_name() in ["Android", "iOS", "Web"]:
		copy_data_to_user()
		db_name = "user://data/train.db"

	_db = SQLite.new()
	_db.path = db_name
	_db.foreign_keys = true
	_db.verbosity_level = SQLite.NORMAL # .VERBOSE
	_db.open_db()

	# session
	# _db.drop_table(table_name)
	_db.query("CREATE TABLE IF NOT EXISTS session (
			id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			ctime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
			type_id INT NOT NULL,
			fitness FLOAT
		)
	")

	# walk_param
	_db.query("CREATE TABLE IF NOT EXISTS walk_param (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		session_id INTEGER not null,
		joint TEXT not null,
		range float not null,
		FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE ON UPDATE RESTRICT
		)
	")



func copy_data_to_user() -> void:
	var data_path := "res://data"
	var copy_path := "user://data"

	DirAccess.make_dir_absolute(copy_path)
	var dir = DirAccess.open(data_path)
	if dir:
		dir.list_dir_begin();
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				print("Copying " + file_name + " to /user-folder")
				dir.copy(data_path + "/" + file_name, copy_path + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func db_call_async(action: Callable) -> void:
	while _do_async:
		await get_tree().process_frame
	_do_async = true
	var state := { "is_done": false }
	var task_id := WorkerThreadPool.add_task(func():
		action.call()
		state["is_done"] = true
	)
	while not state["is_done"]:
		await get_tree().process_frame
	WorkerThreadPool.wait_for_task_completion(task_id)
	_do_async = false


func query_async(query_string: String) -> Array:
	var result := {}
	await db_call_async(func():
		_db.query(query_string)
		result["data"] = _db.query_result
	)
	return result["data"]

func select_rows_async(table_name: String, conditions: String, columns: Array) -> Array:
	var result := {}
	await db_call_async(func():
		result["data"] = _db.select_rows(table_name, conditions, columns)
	)
	return result["data"]

func save_walk_session(type_id: int, fitness: float, param: Array) -> void:
	await db_call_async(func():
		_db.insert_row("session", { "type_id": type_id, "fitness": fitness })
		var session_id = _db.last_insert_rowid
		for p in param:
			p["session_id"] = session_id
		_db.insert_rows("walk_param", param)
	)



func update_walk_session(session_id: int, fitness: float) -> void:
	await db_call_async(func():
		_db.update_rows("session", "id = {0}".format([session_id]), { "fitness": fitness })
	)



