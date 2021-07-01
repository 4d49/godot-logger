# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends Node


signal message(message)


const PROJECT_SETTINGS = "editor_plugins/log/"
const PROJECT_SETTINGS_LOG_ENABLED = PROJECT_SETTINGS + "log_enabled"
const PROJECT_SETTINGS_FILE_WRTITE = PROJECT_SETTINGS + "file/log_file_write"
const PROJECT_SETTINGS_STDOUT = PROJECT_SETTINGS + "log_stdout"

const PROJECT_SETTINGS_FILE_PATH = PROJECT_SETTINGS + "file/file_path"
const PROJECT_SETTINGS_FILE_PATH_DEFAULT = "res://game.log"

const PROJECT_SETTINGS_LEVEL = PROJECT_SETTINGS + "level"

const PROJECT_SETTINGS_FORMAT_TIME = PROJECT_SETTINGS + "format/time"
const PROJECT_SETTINGS_FORMAT_TIME_DEFAULT = "{hour}:{minute}:{second}"

const PROJECT_SETTINGS_FORMAT_TEXT = PROJECT_SETTINGS + "format/message"
const PROJECT_SETTINGS_FORMAT_TEXT_DEFAULT = "[{time}][{level}]{text}"

const INFO    = 1
const DEBUG   = 1<<1
const WARNING = 1<<2
const ERROR   = 1<<3
const FATAL   = 1<<4

# Bitmask level of logger messages.
var _level : int

var _enabled_log        : bool = false
var _enabled_stdout     : bool = false
var _enabled_file_write : bool = false

var _file : File
var _file_path : String

var _format_time : String
var _format_text : String

var _level_name = {
	INFO: "INFO",
	DEBUG: "DEBUG",
	WARNING: "WARNING",
	ERROR: "ERROR",
	FATAL: "FATAL"
}


func _init_setting(setting: String, value):
	if ProjectSettings.has_setting(setting):
		return ProjectSettings.get_setting(setting)
	
	ProjectSettings.set_setting(setting, value)
	return value


func _init() -> void:
	set_enabled_log(_init_setting(PROJECT_SETTINGS_LOG_ENABLED, true))
	set_enabled_stdout(_init_setting(PROJECT_SETTINGS_STDOUT, true))
	
	_level = _init_setting(PROJECT_SETTINGS_LEVEL, INFO | DEBUG | WARNING | ERROR | FATAL)
	ProjectSettings.add_property_info(
		{
			"name": PROJECT_SETTINGS_LEVEL,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": "Info,Debug,Warning,Error,Fatal",
			}
		)
	
	_file_path = _init_setting(PROJECT_SETTINGS_FILE_PATH, PROJECT_SETTINGS_FILE_PATH_DEFAULT)
	set_enabled_file_write(_init_setting(PROJECT_SETTINGS_FILE_WRTITE, true))
	
	_format_time = _init_setting(PROJECT_SETTINGS_FORMAT_TIME, PROJECT_SETTINGS_FORMAT_TIME_DEFAULT)
	_format_text = _init_setting(PROJECT_SETTINGS_FORMAT_TEXT, PROJECT_SETTINGS_FORMAT_TEXT_DEFAULT)
	
	return

# Set the filtering level.
func set_level(level: int, value: bool) -> void:
	if value:
		_level |= level
	else:
		_level &= ~level
	
	return


func get_level() -> int:
	return _level


func has_level(level: int) -> bool:
	return _level_name.has(level)


func add_level(level: int, name: String) -> void:
	if level and name:
		if has_level(level):
			assert(false, "Log has '%s' level." % level)
		else:
			_level_name[level] = name
			set_level(level, true)
	else:
		assert(false, "Invalid level.")
	
	return


func get_level_name(level: int) -> String:
	return _level_name[level]


func set_enabled_log(value: bool) -> void:
	_enabled_log = value
	return


func is_enabled_log() -> bool:
	return _enabled_log


func set_enabled_stdout(value: bool) -> void:
	_enabled_stdout = value
	return


func is_enabled_stdout() -> bool:
	return _enabled_stdout


func set_enabled_file_write(value: bool) -> void:
	_enabled_file_write = value
	if _enabled_file_write:
		_open_file()
	else:
		_close_file()
	return


func is_enabled_file_write() -> bool:
	return _enabled_file_write

# Create a info message.
func info(text: String) -> void:
	message(INFO, text)
	return

# Create a debug message.
func debug(text: String) -> void:
	if OS.is_debug_build():
		message(DEBUG, text)
	return

# Create a warning message.
func warning(text: String) -> void:
	message(WARNING, text)
	return

# Create a error message.
func error(text: String) -> void:
	message(ERROR, text)
	return

# Create a fatal error message.
func fatal(text: String) -> void:
	message(FATAL, text)
	return

# Create a message with custom level.
func message(level: int, text: String) -> void:
	assert(text, "Invalid Message")
	if _enabled_log and _level & level:
		var message = OS.get_time()
		message["level"] = level
		message["text"] = text
		
		emit_signal("message", message)
		
		if _enabled_stdout or _enabled_file_write:
			var string = format_message(message)
			if _enabled_stdout:
				print(string)
			
			if _enabled_file_write:
				_file.store_line(string)
	
	return


func format_message(message: Dictionary) -> String:
	return _format_text.format(
		{
			"time": _format_time.format(
				{
					"hour": "%02d" % message.hour,
					"minute":"%02d" % message.minute,
					"second":"%02d" % message.second,
				}
			),
			"level": _level_name[message.level],
			"text": message.text,
		}
	)


func _open_file() -> void:
	if _file:
		_file.close()
	
	_file = File.new()
	var error = _file.open(_file_path, File.WRITE)
	assert(error == OK, "Can't open file")
	return


func _close_file() -> void:
	if _file:
		_file.close()
		_file = null
	
	return
