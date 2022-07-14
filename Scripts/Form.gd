# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Control
class_name gdforms_Form 

signal cancel
signal submit(id, data)
signal data_update(form_id, item_id, data)

enum Notification {CANCEL, NEXT, BACK, SUBMIT, NONE}

export(String) var form_id = ""

var form_data = {}

var current_page = 0

######### Utilities ##########
func get_pages():
	var pages = []
	for child in get_children():
		if child is gdforms_FormPage:
			pages.append(child)
	return pages
	
func _update_page_visibility():
	var i = 0
	for child in get_children():
		if child is gdforms_FormPage:
			child.visible = i == current_page
			if Engine.editor_hint:
				child.set_display_folded(not child.visible)
				child.emit_signal("script_changed")
			i += 1
		
func set_current_page(index:int):
	if index >= 0:
		current_page = index
	_update_page_visibility()
	
func get_current_page():
	var i = 0
	for child in get_children():
		if child is gdforms_FormPage:
			if i == current_page:
				return child
			i += 1
	return null

######### Lifecycle ##########
func _ready():
	_update_page_visibility()

######### Callbacks ##########

func _on_update_form(item_id:String, data):
	form_data[item_id] = data
	
	emit_signal("data_update", form_id, item_id, data)
		
func _on_notify_form(what):
	match what:
		Notification.BACK:
			if current_page > 0:
				current_page -= 1
				_update_page_visibility()
		Notification.NEXT:
			if current_page < get_pages().size() - 1:
				current_page += 1
				_update_page_visibility()
		Notification.CANCEL:
			emit_signal("cancel")
		Notification.SUBMIT:
			_on_submit_form()
	
func _on_submit_form():
	emit_signal("submit", form_id, form_data)
