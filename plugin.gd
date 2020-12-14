# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends EditorPlugin


const AUTOLOAD_LOG_NAME = "Log"
const AUTOLOAD_LOG_PATH = "res://addons/godot-log/scripts/log.gd"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_LOG_NAME, AUTOLOAD_LOG_PATH)
	return


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_LOG_NAME)
	return
