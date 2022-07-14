# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends gdforms_FormItem
class_name gdforms_TextInput

func set_disabled(val:bool):
	.set_disabled(val)
	
	if not is_inside_tree():
		yield(self, "ready")
		
	$TextEdit.readonly = val

func get_data():
	if is_inside_tree():
		return $TextEdit.text
	else:
		return ""


func _on_text_changed():
	update_form()
	
	emit_signal("interaction")
