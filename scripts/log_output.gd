# Copyright (c) 2020-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## LogOutput class.
class_name LogOutput
extends RichTextLabel

## Emited when handle [signal Log.logged] signal.
signal handled()


@export var format_text : String = "[{hour}:{minute}:{second}][{level}]{text}"
@export var colors : Dictionary = {
	Log.INFO: Color.WHITE,
	Log.DEBUG: Color.GRAY,
	Log.WARNING: Color.YELLOW,
	Log.ERROR: Color.RED,
	Log.FATAL: Color.RED,
}


func _enter_tree() -> void:
	if not (Log as Object).is_connected(&"logged", handle_message):
		var error: Error = (Log as Object).connect(&"logged", handle_message)
		assert(error == OK, error_string(error))


func _exit_tree() -> void:
	if (Log as Object).is_connected(&"logged", handle_message):
		(Log as Object).disconnect(&"logged", handle_message)

## Return the level color or [member Color.WHITE].
func get_color(level: int) -> Color:
	return colors.get(level, Color.WHITE)

## Return formatted string from message.
func format(message: Dictionary) -> String:
	return format_text.format(
		{
			"hour": "%02d" % message["hour"],
			"minute": "%02d" % message["minute"],
			"second": "%02d" % message["second"],
			"level": message["level_name"],
			"text": message["text"],
		}
	)

## Handle the message.
func handle_message(message: Dictionary) -> void:
	push_color(get_color(message["level"]))
	append_text(format(message) + "\n")
	pop()

	handled.emit()
