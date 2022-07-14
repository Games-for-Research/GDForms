# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends gdforms_FormItem
class_name gdforms_ValidatedInput

signal input_validated(value)
signal validation_error

export var allowed_characters = "0-9"
export var validation_pattern = "[0-9]{4}"
export(NodePath) var validation_error_message = null

var validation_regex = RegEx.new()
var illegal_character_regex = RegEx.new()
var old_text = ""


func get_data():
	if is_input_valid():
		return $LineEdit.text
	else:
		return ""
	
func is_input_valid():
	if is_inside_tree() and validation_regex.is_valid():
		if validation_regex.search($LineEdit.text):
			return true
	return false
		
func _ready():
	validation_regex.compile("^" + validation_pattern + "$")
	illegal_character_regex.compile("[^" + allowed_characters + "]")

func _set_error_message_visible(value:bool):
	if validation_error_message != null and is_inside_tree():
		var node = get_node_or_null(validation_error_message) as CanvasItem
		if node != null:
			node.visible = value

func _on_text_changed(new_text):
	$LineEdit.text = illegal_character_regex.sub(new_text, "", true)
	$LineEdit.set_cursor_position($LineEdit.text.length())
	
	if  validation_regex.is_valid() and validation_regex.search($LineEdit.text):
		_set_error_message_visible(false)
		emit_signal("input_validated", get_data())
		update_form()
		
	emit_signal("interaction")
		


func _on_focus_exited():
	if validation_regex.search($LineEdit.text):
		_set_error_message_visible(false)
	else:
		emit_signal("validation_error")
		_set_error_message_visible(true)
