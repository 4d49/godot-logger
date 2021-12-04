# Copyright (c) 2020-2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
extends EditorPlugin


const AUTOLOAD_NAME = "Log"
const AUTOLOAD_PATH = "res://addons/godot-log/scripts/logger.gd"

const LOGGER_OUTPUT = "LoggerOutput"
const LOGGER_OUTPUT_SCRIPT = "res://addons/godot-log/scripts/logger_output.gd"
const LOGGER_OUTPUT_ICON = "res://addons/godot-log/icons/logger.svg"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	add_custom_type(LOGGER_OUTPUT, "RichTextLabel", load(LOGGER_OUTPUT_SCRIPT), load(LOGGER_OUTPUT_ICON))


func _exit_tree() -> void:
	remove_custom_type(LOGGER_OUTPUT)
	remove_autoload_singleton(AUTOLOAD_NAME)
