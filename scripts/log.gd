# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node


signal message(message)


const DEFAULT_PATH = "res://log.txt"

const MESSAGE = preload("log_message.gd")
const MESSAGE_LEVEL = MESSAGE.Level


var _enabled_log        : bool = true
var _enabled_stdout     : bool = false
var _enabled_file_write : bool = false

var _file : File


func _ready() -> void:
	set_enabled_file_write(true)
	return


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
		return
	else:
		_close_file()
		return


func is_enabled_file_write() -> bool:
	return _enabled_file_write

# Create a info message.
func info(text: String, tag: String = "") -> void:
	_create_message(MESSAGE_LEVEL.INFO, text, tag)
	return

# Create a debug message.
func debug(text: String, tag: String = "") -> void:
	if OS.is_debug_build():
		_create_message(MESSAGE_LEVEL.DEBUG, text, tag)
	
	return

# Create a warning message.
func warning(text: String, tag: String = "") -> void:
	_create_message(MESSAGE_LEVEL.WARNING, text, tag)
	return

# Create a error message.
func error(text: String, tag: String = "") -> void:
	_create_message(MESSAGE_LEVEL.ERROR, text, tag)
	return


func _create_message(level: int, text: String, tag: String, desc: String = "") -> void:
	if is_enabled_log():
		var message = MESSAGE.new(level, text, tag)
		emit_signal("message", message)
		
		if is_enabled_stdout():
			print(message.to_string())
		
		if is_enabled_file_write():
			_file.store_line(message.to_string())
	
	return


func _open_file() -> int:
	_file = File.new()
	return _file.open(DEFAULT_PATH, File.WRITE)


func _close_file() -> void:
	if _file:
		_file.close()
		_file = null
	
	return
