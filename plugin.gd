# Copyright (c) 2020-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
extends EditorPlugin


const AUTOLOAD_NAME = "Log"
const AUTOLOAD_PATH = "res://addons/godot-logger/scripts/logger.gd"

const LOGGER_OUTPUT = "LoggerOutput"
const LOGGER_OUTPUT_SCRIPT = "res://addons/godot-logger/scripts/logger_output.gd"
const LOGGER_OUTPUT_ICON = "res://addons/godot-logger/icons/log_output.svg"


func _def_settings(name: String, default: Variant) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)

	ProjectSettings.set_initial_value(name, default)


func _enter_tree() -> void:
	_def_settings("plugins/logger/log_enabled", true)
	_def_settings("plugins/logger/default_output", false)

	_def_settings("plugins/logger/level", 31) # The magic number is - INFO | DEBUG | WARNING | ERROR | FATAL
	ProjectSettings.add_property_info(
		{
			"name": "plugins/logger/level",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": "Info,Debug,Warning,Error,Fatal",
			}
		)

	_def_settings("plugins/logger/file/file_path", "res://game.log")
	_def_settings("plugins/logger/file/log_file_write", true)

	_def_settings("plugins/logger/default_output_format", "[{hour}:{minute}:{second}][{level}]{text}")
	_def_settings("plugins/logger/file_format", "[{hour}:{minute}:{second}][{level}]{text}")

	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	add_custom_type(LOGGER_OUTPUT, "RichTextLabel", load(LOGGER_OUTPUT_SCRIPT), load(LOGGER_OUTPUT_ICON))


func _exit_tree() -> void:
	remove_custom_type(LOGGER_OUTPUT)
	remove_autoload_singleton(AUTOLOAD_NAME)
