# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends VBoxContainer


signal show_log() # Call if autoopen is enabled.


const MESSAGE = preload("log_message.gd")
const MESSAGE_LEVEL = MESSAGE.Level

const LEVEL_COLOR = {
	MESSAGE_LEVEL.INFO: Color.white,
	MESSAGE_LEVEL.DEBUG: Color.gray,
	MESSAGE_LEVEL.WARNING: Color.darkorange,
	MESSAGE_LEVEL.ERROR: Color.red,
	}


export(bool) var auto_open : bool = true


var _log_output : RichTextLabel
var _open_check : CheckBox


func _init() -> void:
	_log_output = RichTextLabel.new()
	_log_output.size_flags_horizontal = SIZE_EXPAND_FILL
	_log_output.size_flags_vertical = SIZE_EXPAND_FILL
	_log_output.selection_enabled = true
	_log_output.scroll_following = true
	self.add_child(_log_output)
	
	var btn_box = HBoxContainer.new()
	self.add_child(btn_box)
	
	var btn_spacer = Control.new()
	btn_spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	btn_box.add_child(btn_spacer)
	
	_open_check = CheckBox.new()
	_open_check.text = "Auto open"
	_open_check.pressed = auto_open
	btn_box.add_child(_open_check)
	
	var btn_clear = Button.new()
	btn_clear.text = "Clear"
	btn_clear.connect("pressed", _log_output, "clear")
	btn_box.add_child(btn_clear)
	
	return


func _ready() -> void:
	Log.connect("message", self, "_on_log_message")
	return


func _on_log_message(message: MESSAGE) -> void:
	_log_output.newline()
	_log_output.push_color(LEVEL_COLOR[message.get_level()])
	_log_output.add_text(message.to_string())
	
	if _open_check.pressed:
		emit_signal("show_log")
	
	return
