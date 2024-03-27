# Copyright (c) 2020-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Logger class.
class_name Logger
extends Node

## Emitted when the logger create a message.
signal logged(message: Dictionary)


enum {
	INFO = 1, ## Info level.
	DEBUG = 1<<1, ## Warning level.
	WARNING = 1<<2, ## Debug level.
	ERROR = 1<<3, ## Error level.
	FATAL = 1<<4, ## Fatal level.
	MAX = FATAL, ## Bitwise left shift for custom levels.
}


var _level : int

var _log_enabled : bool
var _default_output_enabled : bool
var _file_write_enabled : bool

var _file : FileAccess
var _file_path : String

var _format_default_output : String
var _format_file : String

var _names = {
	INFO: "INFO",
	DEBUG: "DEBUG",
	WARNING: "WARNING",
	ERROR: "ERROR",
	FATAL: "FATAL"
}

# Can be overridden to define custom default values.
func _enter_tree() -> void:
	set_log_enabled(ProjectSettings.get_setting("plugins/logger/log_enabled", true))
	set_default_output_enabled(ProjectSettings.get_setting("plugins/logger/default_output", false))

	_level = ProjectSettings.get_setting("plugins/logger/level", INFO | DEBUG | WARNING | ERROR | FATAL)

	set_file_path(ProjectSettings.get_setting("plugins/logger/file/file_path", "res://game.log"))
	set_file_write_enabled(ProjectSettings.get_setting("plugins/logger/file/log_file_write", true))

	_format_default_output = ProjectSettings.get_setting("plugins/logger/default_output_format", "[{hour}:{minute}:{second}][{level}]{text}")
	_format_file = ProjectSettings.get_setting("plugins/logger/file_format", "[{hour}:{minute}:{second}][{level}]{text}")


func _exit_tree() -> void:
	_close_file()

## Return [param true] if logger has level.
func has_level(level: int) -> bool:
	return _names.has(level)

## Set the level enabled.
func set_level(level: int, enabled: bool) -> void:
	assert(has_level(level), "Invalid level.")
	if not has_level(level):
		return

	if enabled:
		_level |= level
	else:
		_level &= ~level

## Add a custom log level. The level value must be unique and be greater than [member MAX].
## To call the custom level use [method message] method.
func add_level(level: int, name: String) -> void:
	assert(not has_level(level), "Has level.")
	assert(level > MAX and not level % 2, "Invalid level.")
	assert(name, "Invalid name.")

	if not has_level(level) and level > MAX and not level % MAX and not name.is_empty():
		_names[level] = name
		set_level(level, true)

## Return the level name.
func get_level_name(level: int) -> String:
	return _names[level]

## Set Log enabled. Disable ALL messages.
func set_log_enabled(enabled: bool) -> void:
	_log_enabled = enabled

## Return [param true] if Log enabled.
func is_log_enabled() -> bool:
	return _log_enabled

## Set default output enabled.
func set_default_output_enabled(enabled: bool) -> void:
	_default_output_enabled = enabled

## Returns [param true] if default output is enabled.
func is_default_output_enabled() -> bool:
	return _default_output_enabled

## Set file write enabled.
func set_file_write_enabled(enabled: bool) -> void:
	if _file_write_enabled == enabled:
		return

	_file_write_enabled = enabled

	if enabled:
		_open_file()
	else:
		_close_file()

## Returns [param true] if write to a file is enabled.
func is_file_write_enabled() -> bool:
	return _file_write_enabled

## Set the path to the log file.
func set_file_path(path: String) -> void:
	assert(path.is_absolute_path(), "Invalid path.")
	if not path.is_absolute_path() or _file_path == path:
		return

	_file_path = path

	if is_file_write_enabled():
		_open_file()

## Return path to log file.
func get_file_path() -> String:
	return _file_path

## Create an info message.
func info(text: String) -> void:
	message(INFO, text)

## Create a debug message. Debug build only.
func debug(text: String) -> void:
	if OS.is_debug_build():
		message(DEBUG, text)

## Create a warning message.
func warning(text: String) -> void:
	message(WARNING, text)

## Create an error message.
func error(text: String) -> void:
	message(ERROR, text)

## Create a fatal error message.
func fatal(text: String) -> void:
	message(FATAL, text)

## Format string for log file.
func format_file(message: Dictionary) -> String:
	return _format_file.format(
		{
			"hour": "%02d" % message["hour"],
			"minute":"%02d" % message["minute"],
			"second":"%02d" % message["second"],
			"level": _names[message["level"]],
			"text": message["text"],
		}
	)

## Format string for editor output.
func format_stdout(message: Dictionary) -> String:
	return _format_default_output.format(
		{
			"hour": "%02d" % message["hour"],
			"minute":"%02d" % message["minute"],
			"second":"%02d" % message["second"],
			"level": _names[message["level"]],
			"text": message["text"],
		}
	)

## Create a message with a custom level.
func message(level: int, text: String) -> void:
	assert(has_level(level), "Has not level.")
	assert(text, "Invalid message text.")

	if _log_enabled and _level & level:
		var message : Dictionary = Time.get_time_dict_from_system()
		message["level"] = level
		message["level_name"] = _names[level]
		message["text"] = text

		logged.emit(message)

		if _file_write_enabled:
			_file.store_line(format_file(message))

		if _default_output_enabled:
			print(format_stdout(message))


func _open_file() -> void:
	if is_instance_valid(_file) and _file.is_open():
		_file.close()

	_file = FileAccess.open(get_file_path(), FileAccess.WRITE)

	var error := FileAccess.get_open_error()
	if error:
		return print_debug(error_string(error))

	error = _file.get_error()
	if error:
		return print_debug(error_string(error))


func _close_file() -> void:
	if is_instance_valid(_file) and _file.is_open():
		_file = null
