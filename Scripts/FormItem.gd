# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This is the base class for all controls that provide data to a form.

tool
extends MarginContainer
class_name gdforms_FormItem

# This signal is sent whenever the data associated with an item changes
# and the form needs to be updated.
# The data parameter must be representable as JSON.
signal update_item(item_id, data)

# Send a notification to the parent form. Valid values are:
# Form.Notification.CANCEL
# Form.Notification.BACK
# Form.Notification.NEXT
# Form.Notification.SUBMIT
signal item_notification(what)

# This is sent when the user interacts with the item.
signal interaction

# The item_id is a string that uniquely identifies an item in a form, and
# will be used as a key to identify this item's data.
# If the item_id is left blank, *the data will not be stored in the form*.
export(String) var item_id = "" setget set_item_id

export(bool) var disabled setget set_disabled, get_disabled

func set_item_id(value):
	item_id = str(value)
	
func set_disabled(val):
	disabled = bool(val)
	
func get_disabled():
	return disabled

# Sends a signal notifying the form needs to be updated, if item_id is not empty.
# Use this instead of calling emit_signal directly.
func update_form():
	if item_id != "" and not Engine.editor_hint:
		emit_signal("update_item", item_id, get_data())

# Send a notification to the parent form. Valid values are:
# Form.Notification.CANCEL
# Form.Notification.BACK
# Form.Notification.NEXT
# Form.Notification.SUBMIT
func notify_form(what):
	if not Engine.editor_hint:
		emit_signal("item_notification", what)

# You must override this method in classes that inherit from FormItem.
# The data returned must be expressable as JSON.
func get_data():
	push_error("You must override the get_data method in form items!")

# Display a warning in the inspector when no item id is set.
func _get_configuration_warning():
	if item_id == "":
		return "Item Id is empty: values will not be reported to the form and branching will not work."
	return ""
	
func get_form() -> gdforms_Form:
	if is_inside_tree():
		var parent = get_parent()
		while parent != null:
			if parent is gdforms_Form:
				return parent
			parent = parent.get_parent()
	return null

func _enter_tree():
	var form = get_form()
	if form != null:
		var err = connect("item_notification", form, "_on_notify_form")
		if OK != err:
			push_error("Could not connect item_notification signal: " + str(err))
			
		err = connect("update_item", form, "_on_update_form")
		if OK != err:
			push_error("Could not connect update_item signal: " + str(err))
		else:
			update_form()
		
func _exit_tree():
	var form = get_form()
	if form != null:
		disconnect("update_item", form, "_on_update_form")
		disconnect("item_notification", form, "_on_notify_form")
