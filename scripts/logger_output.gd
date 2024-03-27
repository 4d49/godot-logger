# Copyright (c) 2020-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
## LoggerOutput class.
class_name LoggerOutput
extends RichTextLabel

## Emited when handle [signal Logger.logged] signal.
signal handled()


@export var format_text : String = "[{hour}:{minute}:{second}][{level}]{text}"
@export var colors : Dictionary = {
	Logger.INFO: Color.WHITE,
	Logger.DEBUG: Color.GRAY,
	Logger.WARNING: Color.YELLOW,
	Logger.ERROR: Color.RED,
	Logger.FATAL: Color.RED,
}


var _logger : Logger


func _enter_tree() -> void:
	var logger := get_node_or_null("/root/Log") as Logger
	if is_instance_valid(logger):
		set_logger(logger)


func _exit_tree() -> void:
	if is_instance_valid(_logger) and _logger.logged.is_connected(handle_message):
		_logger.logged.disconnect(handle_message)

## Return the level color or [member Color.WHITE].
func get_color(level: int) -> Color:
	return colors.get(level, Color.WHITE)

## Set the logger.
func set_logger(logger: Logger) -> void:
	assert(is_instance_valid(logger), "Invalid Logger.")
	if not is_instance_valid(logger) or is_same(_logger, logger):
		return

	if is_instance_valid(_logger) and _logger.logged.is_connected(handle_message):
		_logger.logged.disconnect(handle_message)

	if not logger.logged.is_connected(handle_message):
		logger.logged.connect(handle_message)

	_logger = logger

## Return the logger.
func get_logger() -> Logger:
	return _logger

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
