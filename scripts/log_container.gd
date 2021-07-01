# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends VBoxContainer


signal show_log() # Call if autoopen is enabled.


export(bool) var bottom_visible : bool = true setget set_bottom_visible, is_bottom_visible
export(bool) var auto_open : bool = true setget set_autoopen, is_autoopen

export(String) var format_text : String = "[{hour}:{minute}:{second}][{level}]{text}"

export(Dictionary) var colors : Dictionary = {
	Log.INFO: Color.white,
	Log.DEBUG: Color.gray,
	Log.WARNING: Color.darkorange,
	Log.ERROR: Color.red,
	Log.FATAL: Color.red,
}


var _log_output : RichTextLabel
var _bottom_bar : HBoxContainer
var _open_check : CheckBox


func _init() -> void:
	_log_output = RichTextLabel.new()
	_log_output.size_flags_horizontal = SIZE_EXPAND_FILL
	_log_output.size_flags_vertical = SIZE_EXPAND_FILL
	_log_output.selection_enabled = true
	_log_output.scroll_following = true
	self.add_child(_log_output)
	
	_bottom_bar = HBoxContainer.new()
	_bottom_bar.size_flags_horizontal = SIZE_EXPAND_FILL
	_bottom_bar.visible = bottom_visible
	self.add_child(_bottom_bar)
	
	var btn_spacer = Control.new()
	btn_spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	_bottom_bar.add_child(btn_spacer)
	
	_open_check = CheckBox.new()
	_open_check.text = "Auto open"
	_open_check.pressed = auto_open
	# warning-ignore:return_value_discarded
	_open_check.connect("toggled", self, "set_autoopen")
	_bottom_bar.add_child(_open_check)
	
	var btn_clear = Button.new()
	btn_clear.text = "Clear"
	btn_clear.connect("pressed", _log_output, "clear")
	_bottom_bar.add_child(btn_clear)
	
	# warning-ignore:return_value_discarded
	Log.connect("message", self, "handle_message")
	return


func set_bottom_visible(value: bool) -> void:
	_bottom_bar.visible = value
	return


func is_bottom_visible() -> bool:
	return _bottom_bar.visible


func set_autoopen(value: bool) -> void:
	_open_check.pressed = value
	return


func is_autoopen() -> bool:
	return _open_check.pressed


func get_message_color(level: int) -> Color:
	if colors.has(level):
		return colors[level]
	
	return Color.white


func format(message: Dictionary) -> String:
	return format_text.format(
		{
			"hour": "%02d" % message.hour,
			"minute": "%02d" % message.minute,
			"second": "%02d" % message.second,
			"level": Log.get_level_name(message.level),
			"text": message.text,
		}
	)


func handle_message(message: Dictionary) -> void:
	_log_output.push_color(get_message_color(message.level))
	_log_output.add_text(format(message))
	_log_output.newline()
	
	if is_autoopen():
		emit_signal("show_log")
	
	return
