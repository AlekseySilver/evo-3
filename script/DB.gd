extends Node

var _db : SQLite = null
var db_name := "res://data/train.db"

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
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		ctime DATETIME DEFAULT CURRENT_TIMESTAMP,
		fitness float
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


func save_walk_session(fitness: float, param: Array) -> void:
	_db.insert_row("session", { "fitness": fitness })
	var session_id = _db.last_insert_rowid
	for p in param:
		p["session_id"] = session_id
	_db.insert_rows("walk_param", param)