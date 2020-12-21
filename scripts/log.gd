# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends Node


signal message(message)


const MESSAGE = preload("log_message.gd")

const DEFAULT_PATH = "res://log.txt"

const INFO    = 1<<1
const DEBUG   = 1<<2
const WARNING = 1<<3
const ERROR   = 1<<4
const FATAL   = 1<<5

# Bitmask level of logger messages.
var _level : int = INFO | DEBUG | WARNING | ERROR | FATAL

var _enabled_log        : bool = false
var _enabled_stdout     : bool = false
var _enabled_file_write : bool = false

var _file : File

var _format_time : String = "{hour}:{minute}:{second}"
var _format_text : String = "[{time}][{level}]{text}"

var _level_name = {
	INFO: "INFO",
	DEBUG: "DEBUG",
	WARNING: "WARNING",
	ERROR: "ERROR",
	FATAL: "FATAL"
}

func _ready() -> void:
	set_enabled_log(true)
	set_enabled_file_write(true)
	set_enabled_stdout(true)
	return

# Set the filtering level.
func set_level(level: int, value: bool) -> void:
	if value:
		_level |= level
	else:
		_level &= ~level


func get_level() -> int:
	return _level


func add_level(level: int, name: String) -> void:
	assert(not _level_name.has(level), "Log has '%s' level" % level)
	assert(name, "Invalid level name")
	_level_name[level] = name
	# Enable custom level.
	set_level(level, true)
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


func is_enabled_file_write() -> bool:
	return _enabled_file_write


func set_format_time(format: String) -> void:
	_format_time = format
	return


func set_format_text(format: String) -> void:
	_format_text = format
	return

# Create a info message.
func info(text: String) -> void:
	if get_level() & INFO:
		_create_message(INFO, text)
	
	return

# Create a debug message.
func debug(text: String) -> void:
	if OS.is_debug_build() and get_level() & DEBUG:
		_create_message(DEBUG, text)
	
	return

# Create a warning message.
func warning(text: String) -> void:
	if get_level() & WARNING:
		_create_message(WARNING, text)
	
	return

# Create a error message.
func error(text: String) -> void:
	if get_level() & ERROR:
		_create_message(ERROR, text)
	
	return

# Create a fatal error message.
func fatal(text: String) -> void:
	if get_level() & FATAL:
		_create_message(FATAL, text)
	
	return

# Create a message with custom level.
func message(level: int, text: String) -> void:
	if get_level() & level:
		_create_message(level, text)
	
	return


func format(message: MESSAGE) -> String:
	var time = message.get_time()
	return _format_text.format(
		{
			"time": _format_time.format(
				{
					"hour":  "%02d" % time.hour,
					"minute":"%02d" % time.minute,
					"second":"%02d" % time.second,
				}
			),
			"level": get_level_name(message.get_level()),
			"text": message.get_text(),
		}
	)


func _create_message(level: int, text: String) -> void:
	if is_enabled_log():
		var message = MESSAGE.new(level, text, OS.get_time())
		emit_signal("message", message)
		
		var string = format(message)
		if is_enabled_stdout():
			print(string)
		
		if is_enabled_file_write():
			_file.store_line(string)
	
	return


func _open_file() -> int:
	if _file:
		_file.close()
	
	_file = File.new()
	return _file.open(DEFAULT_PATH, File.WRITE)


func _close_file() -> void:
	if _file:
		_file.close()
		_file = null
	
	return
