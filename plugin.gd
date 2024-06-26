# Copyright (c) 2020-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
extends EditorPlugin


const LOGGER_OUTPUT = "LogOutput"
const LOGGER_OUTPUT_SCRIPT = "res://addons/godot-logger/scripts/log_output.gd"
const LOGGER_OUTPUT_ICON = "res://addons/godot-logger/icons/log_output.svg"


func _def_settings(name: String, default: Variant) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)

	ProjectSettings.set_initial_value(name, default)


func _enter_tree() -> void:
	_def_settings("plugins/log/log_enabled", true)
	_def_settings("plugins/log/default_output", false)

	_def_settings("plugins/log/level", 31) # The magic number is - INFO | DEBUG | WARNING | ERROR | FATAL
	ProjectSettings.add_property_info(
		{
			"name": "plugins/log/level",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": "Info,Debug,Warning,Error,Fatal",
			}
		)

	_def_settings("plugins/log/file/file_path", "res://game.log")
	_def_settings("plugins/log/file/log_file_write", true)

	_def_settings("plugins/log/default_output_format", "[{hour}:{minute}:{second}][{level}]{text}")
	_def_settings("plugins/log/file_format", "[{hour}:{minute}:{second}][{level}]{text}")

	add_custom_type(LOGGER_OUTPUT, "RichTextLabel", load(LOGGER_OUTPUT_SCRIPT), load(LOGGER_OUTPUT_ICON))


func _exit_tree() -> void:
	remove_custom_type(LOGGER_OUTPUT)
