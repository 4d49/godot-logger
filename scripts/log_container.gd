# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends VBoxContainer


signal show_log() # Call if autoopen is enabled.


const MESSAGE = preload("log_message.gd")

const MESSAGE_TAG = Log.MESSAGE_TAG
const MESSAGE_FORMAT = "[{time}][{tag}]{text}"

const LEVEL_COLOR = {
	Log.INFO: Color.white,
	Log.DEBUG: Color.gray,
	Log.WARNING: Color.darkorange,
	Log.ERROR: Color.red,
	}


export(bool) var auto_open : bool = true # Used only in init.


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


func get_message_color(level: int) -> Color:
	return LEVEL_COLOR[level]


func _message_to_text(message: MESSAGE) -> String:
	if message.has_tag():
		return MESSAGE_FORMAT.format(
			{
				"time": message.get_time(),
				"tag" : message.get_tag(),
				"text": message.get_text(),
			}
		)
	
	return MESSAGE_FORMAT.format(
		{
			"time": message.get_time(),
			"tag" : MESSAGE_TAG[message.get_level()],
			"text": message.get_text(),
		}
	)


func _on_log_message(message: MESSAGE) -> void:
	_log_output.newline()
	_log_output.push_color(get_message_color(message.get_level()))
	_log_output.add_text(_message_to_text(message))
	
	if _open_check.pressed:
		emit_signal("show_log")
	
	return
