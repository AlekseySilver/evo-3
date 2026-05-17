class_name PythonRunner extends RefCounted

var _thread: Thread

signal run_completed(exit_code: int, output: Array)

func fire(script: String, args: Array = []) -> void:
	var script_path := ProjectSettings.globalize_path("res://script/python/{0}.py".format([script]))
	print(script_path)
	if not FileAccess.file_exists(script_path):
		run_completed.emit(-1, ["script file not exists at " + script_path])
		return

	args.insert(0, script_path)
	_thread = Thread.new()
	_thread.start(_run_task.bind(args))

func _run_task(args: Array) -> void:
	var output := []
	var python_path := ProjectSettings.globalize_path("res://.venv/Scripts/python.exe")
	print(python_path)
	var exit_code := OS.execute(python_path, args, output, true, false)
	call_deferred("_task_finished", exit_code, output)

func _task_finished(exit_code: int, output: Array) -> void:
	_thread.wait_to_finish()
	run_completed.emit(exit_code, output)
