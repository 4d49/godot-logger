# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends Node


signal message(message)


const DEFAULT_PATH = "res://log.txt"

const MESSAGE = preload("log_message.gd")

const INFO = 1<<1
const DEBUG = 1<<2
const WARNING = 1<<3
const ERROR = 1<<4

const MESSAGE_TAG = {
	INFO: "INFO",
	DEBUG: "DEBUG",
	WARNING: "WARNING",
	ERROR: "ERROR",
}

const FORMAT_MESSAGE     = "[{time}][{level}]{text}"
const FORMAT_MESSAGE_TAG = "[{time}][{level}][{tag}]{text}"

# Filtering level of logger messages.
var _level_bit : int = INFO | DEBUG | WARNING | ERROR

var _enabled_log        : bool = false
var _enabled_stdout     : bool = false
var _enabled_file_write : bool = false

var _file : File


func _ready() -> void:
	set_enabled_log(true)
	set_enabled_file_write(true)
	set_enabled_stdout(false)
	return

# Set the filtering level.
func set_level_bit(bit: int, value: bool) -> void:
	if value:
		_level_bit |= bit
	else:
		_level_bit &= ~bit


func get_level_bit() -> int:
	return _level_bit


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
	if get_level_bit() & INFO:
		_create_message(INFO, text, tag)
	
	return

# Create a debug message.
func debug(text: String, tag: String = "") -> void:
	if OS.is_debug_build() and get_level_bit() & DEBUG:
		_create_message(DEBUG, text, tag)
	
	return

# Create a warning message.
func warning(text: String, tag: String = "") -> void:
	if get_level_bit() & WARNING:
		_create_message(WARNING, text, tag)
	
	return

# Create a error message.
func error(text: String, tag: String = "") -> void:
	if get_level_bit() & ERROR:
		_create_message(ERROR, text, tag)
	
	return

# Create a message with a custom bit.
func message(text: String, bit: int, tag: String = "") -> void:
	if get_level_bit() & bit:
		_create_message(bit, text, tag)
	
	return


func _message_to_stdout(message: MESSAGE) -> String:
	if message.has_tag():
		return FORMAT_MESSAGE_TAG.format(
			{
				"time" : message.get_time(),
				"level": MESSAGE_TAG[message.get_level()],
				"tag"  : message.get_tag(),
				"text" : message.get_text(),
			}
		)
	return FORMAT_MESSAGE.format(
		{
			"time" : message.get_time(),
			"level": MESSAGE_TAG[message.get_level()],
			"text" : message.get_text(),
		}
	)


func _message_to_line(message: MESSAGE) -> String:
	if message.has_tag():
		return FORMAT_MESSAGE_TAG.format(
			{
				"time" : message.get_time(),
				"level": message.get_level(),
				"tag"  : message.get_tag(),
				"text" : message.get_text(),
			}
		)
	
	return FORMAT_MESSAGE.format(
		{
			"time" : message.get_time(),
			"level": message.get_level(),
			"text" : message.get_text(),
		}
	)


func _create_message(level: int, text: String, tag: String, desc: String = "") -> void:
	if is_enabled_log():
		var message = MESSAGE.new(level, text, tag)
		emit_signal("message", message)
		
		if is_enabled_stdout():
			print(_message_to_stdout(message))
		
		if is_enabled_file_write():
			_file.store_line(_message_to_line(message))
	
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
