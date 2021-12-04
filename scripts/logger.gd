# Copyright (c) 2020-2021 Mansur Isaev and contributors - MIT License
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
var _stdout_enabled : bool
var _file_write_enabled : bool

var _file : File
var _file_path : String

var _format_stdout : String
var _format_file : String

var _names = {
	INFO: "INFO",
	DEBUG: "DEBUG",
	WARNING: "WARNING",
	ERROR: "ERROR",
	FATAL: "FATAL"
}


func _init_setting(setting: String, value: Variant) -> Variant:
	if ProjectSettings.has_setting(setting):
		return ProjectSettings.get_setting(setting)
	
	ProjectSettings.set_setting(setting, value)
	return value


func _init() -> void:
	const LOGGER_SETTINGS = "editor_plugins/logger/" # Path to Log settings in Project Settings.
	
	set_log_enabled(_init_setting(LOGGER_SETTINGS + "log_enabled", true))
	set_stdout_enabled(_init_setting(LOGGER_SETTINGS + "log_stdout", false))
	
	const LOGGER_SETTINGS_LEVEL = LOGGER_SETTINGS + "level"
	
	_level = _init_setting(LOGGER_SETTINGS_LEVEL, INFO | DEBUG | WARNING | ERROR | FATAL)
	ProjectSettings.add_property_info(
		{
			"name": LOGGER_SETTINGS_LEVEL,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": "Info,Debug,Warning,Error,Fatal",
			}
		)
	
	set_file_write_enabled(_init_setting(LOGGER_SETTINGS + "file/log_file_write", true))
	set_file_path(_init_setting(LOGGER_SETTINGS + "file/file_path", "res://game.log"))
	
	_format_stdout = _init_setting(LOGGER_SETTINGS + "stdout_format", "[{hour}:{minute}:{second}][{level}]{text}")
	_format_file = _init_setting(LOGGER_SETTINGS + "file_format", "[{hour}:{minute}:{second}][{level}]{text}")

## Return [code]true[/code] if logger has level.
func has_level(level: int) -> bool:
	return _names.has(level)

## Set the level enabled.
func set_level(level: int, enabled: bool) -> void:
	assert(has_level(level), "Invalid level.")
	if has_level(level):
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

## Return [code]true[/code] if Log enabled.
func is_log_enabled() -> bool:
	return _log_enabled

## Set stdout enabled.
func set_stdout_enabled(enabled: bool) -> void:
	_stdout_enabled = enabled

## Return [code]true[/code] if stdout enabled.
func is_stdout_enabled() -> bool:
	return _stdout_enabled

## Set file write enabled.
func set_file_write_enabled(enabled: bool) -> void:
	if _file_write_enabled != enabled:
		_file_write_enabled = enabled
		
		if enabled:
			_open_file()
		else:
			_close_file()

## Returns [code]true[/code] if write to a file is enabled.
func is_file_write_enabled() -> bool:
	return _file_write_enabled

## Set the path to the log file.
func set_file_path(path: String) -> void:
	assert(path.is_absolute_path(), "Invalid path.")
	if _file_path != path and path.is_absolute_path():
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
	return _format_stdout.format(
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
		var message = Time.get_time_dict_from_system()
		message["level"] = level
		message["text"] = text
		
		logged.emit(message)
		
		if _file_write_enabled:
			_file.store_line(format_file(message))
		
		if _stdout_enabled:
			print(format_stdout(message))


func _open_file() -> int:
	if is_instance_valid(_file):
		_file.close()
	
	_file = File.new()
	return _file.open(get_file_path(), File.WRITE)


func _close_file() -> void:
	if is_instance_valid(_file):
		_file.close()
		_file = null
