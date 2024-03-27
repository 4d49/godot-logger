# Copyright (c) 2020-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Log class.
class_name Log
extends Node


enum {
	INFO = 1, ## Info level.
	DEBUG = 1<<1, ## Warning level.
	WARNING = 1<<2, ## Debug level.
	ERROR = 1<<3, ## Error level.
	FATAL = 1<<4, ## Fatal level.
	MAX = FATAL, ## Bitwise left shift for custom levels.
}

# INFO: This is necessary to create a static signal.
const _SELF: Object = preload("res://addons/godot-logger/scripts/log.gd")


static var _level : int

static var _log_enabled : bool
static var _default_output_enabled : bool
static var _file_write_enabled : bool

static var _file : FileAccess
static var _file_path : String

static var _format_default_output : String
static var _format_file : String

static var _names = {
	INFO: "INFO",
	DEBUG: "DEBUG",
	WARNING: "WARNING",
	ERROR: "ERROR",
	FATAL: "FATAL"
}


static func _static_init() -> void:
	# INFO: This is a workaround for creating a static signal.
	_SELF.add_user_signal("logged", [{"name": "message", "type": TYPE_DICTIONARY}])

	set_log_enabled(ProjectSettings.get_setting("plugins/logger/log_enabled", true))
	set_default_output_enabled(ProjectSettings.get_setting("plugins/logger/default_output", false))

	_level = ProjectSettings.get_setting("plugins/logger/level", INFO | DEBUG | WARNING | ERROR | FATAL)

	set_file_path(ProjectSettings.get_setting("plugins/logger/file/file_path", "res://game.log"))
	set_file_write_enabled(ProjectSettings.get_setting("plugins/logger/file/log_file_write", true))

	_format_default_output = ProjectSettings.get_setting("plugins/logger/default_output_format", "[{hour}:{minute}:{second}][{level}]{text}")
	_format_file = ProjectSettings.get_setting("plugins/logger/file_format", "[{hour}:{minute}:{second}][{level}]{text}")

## Return [param true] if logger has level.
static func has_level(level: int) -> bool:
	return _names.has(level)

## Set the level enabled.
static func set_level(level: int, enabled: bool) -> void:
	assert(has_level(level), "Invalid level.")
	if not has_level(level):
		return

	if enabled:
		_level |= level
	else:
		_level &= ~level

## Add a custom log level. The level value must be unique and be greater than [member MAX].
## To call the custom level use [method message] method.
static func add_level(level: int, name: String) -> void:
	assert(not has_level(level), "Has level.")
	assert(level > MAX and not level % 2, "Invalid level.")
	assert(name, "Invalid name.")

	if not has_level(level) and level > MAX and not level % MAX and not name.is_empty():
		_names[level] = name
		set_level(level, true)

## Return the level name.
static func get_level_name(level: int) -> String:
	return _names[level]

## Set Log enabled. Disable ALL messages.
static func set_log_enabled(enabled: bool) -> void:
	_log_enabled = enabled

## Return [param true] if Log enabled.
static func is_log_enabled() -> bool:
	return _log_enabled

## Set default output enabled.
static func set_default_output_enabled(enabled: bool) -> void:
	_default_output_enabled = enabled

## Returns [param true] if default output is enabled.
static func is_default_output_enabled() -> bool:
	return _default_output_enabled

## Set file write enabled.
static func set_file_write_enabled(enabled: bool) -> void:
	if _file_write_enabled == enabled:
		return

	_file_write_enabled = enabled

	if enabled:
		_open_file()
	else:
		_close_file()

## Returns [param true] if write to a file is enabled.
static func is_file_write_enabled() -> bool:
	return _file_write_enabled

## Set the path to the log file.
static func set_file_path(path: String) -> void:
	assert(path.is_absolute_path(), "Invalid path.")
	if not path.is_absolute_path() or _file_path == path:
		return

	_file_path = path

	if is_file_write_enabled():
		_open_file()

## Return path to log file.
static func get_file_path() -> String:
	return _file_path

## Create an info message.
static func info(text: String) -> void:
	message(INFO, text)

## Create a debug message. Debug build only.
static func debug(text: String) -> void:
	if OS.is_debug_build():
		message(DEBUG, text)

## Create a warning message.
static func warning(text: String) -> void:
	message(WARNING, text)

## Create an error message.
static func error(text: String) -> void:
	message(ERROR, text)

## Create a fatal error message.
static func fatal(text: String) -> void:
	message(FATAL, text)

## Format string for log file.
static func format_file(message: Dictionary) -> String:
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
static func format_stdout(message: Dictionary) -> String:
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
static func message(level: int, text: String) -> void:
	assert(has_level(level), "Has not level.")
	assert(text, "Invalid message text.")

	if _log_enabled and _level & level:
		var message : Dictionary = Time.get_time_dict_from_system()
		message["level"] = level
		message["level_name"] = _names[level]
		message["text"] = text

		_SELF.emit_signal(&"logged", message)

		if _file_write_enabled:
			_file.store_line(format_file(message))

		if _default_output_enabled:
			print(format_stdout(message))


static func _open_file() -> void:
	if is_instance_valid(_file) and _file.is_open():
		_file.close()

	_file = FileAccess.open(get_file_path(), FileAccess.WRITE)

	var error := FileAccess.get_open_error()
	if error:
		return print_debug(error_string(error))

	error = _file.get_error()
	if error:
		return print_debug(error_string(error))


static func _close_file() -> void:
	if is_instance_valid(_file) and _file.is_open():
		_file = null
