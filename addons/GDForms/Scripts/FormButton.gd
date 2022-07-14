# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends gdforms_FormItem
class_name gdforms_FormButton

# The type of notification sent by the button. See Forms.gd for details.
export(gdforms_Form.Notification) var notification = gdforms_Form.Notification.NONE

# The text displayed in the button.
export(String) var text = "" setget set_text, get_text

var was_interacted = false

# Buttons do not need to report their values to the form and so we 
# override this method to not display a warning in the editor.
func _get_configuration_warning():
	return ""

# We remember if the button was interacted with. Use this method to reset this value.
func reset():
	was_interacted = false

# A wrapper to access the standard Button's properties. 
func set_disabled(value:bool):
	disabled = value
	if is_inside_tree():
		get_button().disabled = value

# A wrapper to access the standard Button's properties. 
func get_disabled():
	if is_inside_tree():
		return get_button().disabled
	return true

# A wrapper to access the standard Button's properties. 
func set_text(value:String):
	text = value
	if is_inside_tree():
		get_button().text = value

# A wrapper to access the standard Button's properties. 
func get_text():
	if is_inside_tree():
		return get_button().text
	return text

# Return a reference to the actual Button.
func get_button():
	if is_inside_tree():
		return $CenterContainer/Button
	else:
		return null

# Here we return whether the button was interacted with.
func get_data():
	return was_interacted

######### Lifecycle ##########

func _ready():
	set_text(text)

######### Callbacks ##########

func _on_Button_pressed():
	was_interacted = true
	
	notify_form(notification)
	
	emit_signal("interaction")


