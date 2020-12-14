# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference

# Levels for message.
enum Level {
	INFO,
	DEBUG,
	WARNING,
	ERROR,
	}

# Tags for the level.
const LEVEL_TAG = {
	Level.INFO:    "INFO",
	Level.DEBUG:   "DEBUG",
	Level.WARNING: "WARNING",
	Level.ERROR:   "ERROR",
	}

const FORMAT_TIME   = "{hour}:{minute}:{second}"
const FORMAT_STRING = "[{time}] [{tag}] {text}"


var _level : int
var _text  : String
var _tag   : String
var _time  : Dictionary # OS.get_time().


func _init(level: int, text: String, tag: String = "") -> void:
	self._set_level(level)
	self._set_text(text)
	self._set_tag(tag)
	self._set_time(OS.get_time())
	return


func _to_string() -> String:
	return FORMAT_STRING.format(
		{
			"time": get_time(),
			"tag": get_tag(),
			"text": get_text()
		}
	)


func get_level() -> int:
	return _level


func get_text() -> String:
	return _text


func get_tag() -> String:
	return _tag

# Returns the time as a string.
func get_time() -> String:
	return FORMAT_TIME.format(_get_time())


func _set_level(level: int) -> void:
	assert(LEVEL_TAG.has(level), "Invalid level.")
	_level = level
	return


func _set_text(text: String) -> void:
	assert(not text.empty(), "Empty text.")
	_text = text
	return


func _set_tag(tag: String) -> void:
	if tag.empty():
		tag = LEVEL_TAG[get_level()]
	
	_tag = tag
	return


func _set_time(time: Dictionary) -> void:
	assert(time.has("hour") and time.has("minute") and time.has("second"), "Invalid time dictionary.")
	_time = time
	return

# Returns message time as a dictionary.
func _get_time() -> Dictionary:
	return _time
