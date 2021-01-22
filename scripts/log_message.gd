# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference


var _level : int
var _text  : String
var _time  : Dictionary # OS.get_time().


func _init(level: int, text: String, time: Dictionary) -> void:
	self._set_level(level)
	self._set_text(text)
	self._set_time(time)
	return


func _to_string() -> String:
	return "[Message:%s]" % get_text()


func get_level() -> int:
	return _level


func get_text() -> String:
	return _text


func get_time() -> Dictionary:
	return _time


func _set_level(level: int) -> void:
	_level = level
	return


func _set_text(text: String) -> void:
	assert(text, "Invalid text.")
	_text = text
	return


func _set_time(time: Dictionary) -> void:
	assert(time, "Invalid time.")
	_time = time
	return
