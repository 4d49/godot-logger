# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends EditorPlugin


const AUTOLOAD_LOG_NAME = "Log"
const AUTOLOAD_LOG_PATH = "res://addons/godot-log/scripts/log.gd"

const LOG_CONTAINER_NAME = "LogContainer"
const LOG_CONTAINER_SCRIPT = "res://addons/godot-log/scripts/log_container.gd"
const LOG_CONTAINER_ICON = "res://addons/godot-log/icons/log_icon.svg"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_LOG_NAME, AUTOLOAD_LOG_PATH)
	add_custom_type(LOG_CONTAINER_NAME, "VBoxContainer", load(LOG_CONTAINER_SCRIPT), load(LOG_CONTAINER_ICON))
	return


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_LOG_NAME)
	remove_custom_type(LOG_CONTAINER_NAME)
	return
