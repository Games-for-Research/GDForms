# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This class is a wrapper for the standard Godot Checkbox.
# The label can be positioned to the left, right, above and below the button.

tool
extends Node
class_name gdforms_Branch

enum Type {ANY_SELECTION, SPECIFIC_VALUE}
enum AnswerKeyCreteria {ALL_ANSWERS, ANY_ANSWER}

export(NodePath) var target = null
export(NodePath) var alternate_target = null
export(NodePath) var disable_target = null

var _condition_type = Type.ANY_SELECTION
var checkbox_value = true

var text = ""
var options_index = 0
var _answer_key_criteria = AnswerKeyCreteria.ALL_ANSWERS
var answer_key:PoolIntArray = []
var grid_selections:PoolIntArray = []
var grid_answer_keys:Array = []

var test = ""

func _get(property):
	match property:
		"condition_type":
			return _condition_type
		"checkbox_value":
			return checkbox_value
		"answer_key_criteria":
			return _answer_key_criteria
	return null

func _set(property, value):
	match property:
		"condition_type":
			_condition_type = int(value)
			property_list_changed_notify()
			return true
		"checkbox_value":
			checkbox_value = value
			return true
		"answer_key_criteria":
			_answer_key_criteria = value
			return true

func _get_property_list():
	var props = []
	if is_inside_tree():
		var parent = get_parent()
		if parent != null:
			
			if parent is gdforms_FormItem and not parent is gdforms_FormButton:
				props.append({
					"hint": PROPERTY_HINT_ENUM,
					"usage": PROPERTY_USAGE_DEFAULT,
					"name": "condition_type",
					"type": TYPE_INT,
					"hint_string": "Any value, Specific value"
				})
			
			if parent is gdforms_Checkbox:
				if _condition_type == Type.SPECIFIC_VALUE:
					props.append({
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT,
						"name": "checkbox_value",
						"type": TYPE_BOOL
					})
					
			if parent is gdforms_Options:
				if _condition_type == Type.SPECIFIC_VALUE:
					if parent.multiple_selections:
						props.append({
							"hint": PROPERTY_HINT_ENUM,
							"usage": PROPERTY_USAGE_DEFAULT,
							"name": "answer_key_criteria",
							"type": TYPE_INT,
							"hint_string": "All answers, Any answer"
						})
						
						props.append({
							"hint": PROPERTY_HINT_NONE,
							"usage": PROPERTY_USAGE_DEFAULT,
							"name": "answer_key",
							"type": TYPE_INT_ARRAY
						})
					else:
						props.append({
							"hint": PROPERTY_HINT_NONE,
							"usage": PROPERTY_USAGE_DEFAULT,
							"name": "options_index",
							"type": TYPE_INT
						})
						
			if parent is gdforms_OptionsGrid:
				if _condition_type == Type.SPECIFIC_VALUE:
					if parent.multiple_selections:
						props.append({
							"hint": PROPERTY_HINT_ENUM,
							"usage": PROPERTY_USAGE_DEFAULT,
							"name": "answer_key_criteria",
							"type": TYPE_INT,
							"hint_string": "All answers, Any answer"
						})
						
						props.append({
							"hint": PROPERTY_HINT_NONE,
							"usage": PROPERTY_USAGE_DEFAULT,
							"name": "grid_answer_keys",
							"type": TYPE_ARRAY
						})
					else:
						props.append({
							"hint": PROPERTY_HINT_NONE,
							"usage": PROPERTY_USAGE_DEFAULT,
							"name": "grid_selections",
							"type": TYPE_INT_ARRAY
						})
						
			if parent is gdforms_TextInput or parent is gdforms_ValidatedInput:
				if _condition_type == Type.SPECIFIC_VALUE:
					props.append({
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT,
						"name": "text",
						"type": TYPE_STRING
					})		
					
				
	
	return props


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent() as gdforms_FormItem
	if parent != null:
		var err = parent.connect("update_item", self, "_on_parent_update")
		if OK != err:
			push_error("Could not connect update_item signal")
			
		err = parent.connect("interaction", self, "_on_parent_interaction")
		if OK != err:
			push_error("Could not connect interaction signal")
		
		if Engine.editor_hint:
			if parent is gdforms_OptionsGrid:
				grid_selections.resize(parent.rows.size())
			
		match _condition_type:
			Type.ANY_SELECTION:
				_set_target_state(false)
			Type.SPECIFIC_VALUE:
				_update_state()
		
func _set_target_state(state:bool):
	if Engine.editor_hint:
		return
		
	if target != null:
		var target_node = get_node_or_null(target)
		if target_node != null and target_node is CanvasItem:
			target_node.visible = state
			
	if alternate_target != null:
		var target_node = get_node_or_null(alternate_target)
		if target_node != null and target_node is CanvasItem:
			target_node.visible = not state
			
	if disable_target != null:
		var target_node = get_node_or_null(disable_target)
		if target_node != null and target_node.has_method("set_disabled"):
			target_node.set_disabled(state)
		
		
func _update_state():
	var parent = get_parent() as gdforms_FormItem
	var valid = false
	if parent != null:
		
		if parent is gdforms_Checkbox:
			valid = parent.get_data() == checkbox_value
			
		if parent is gdforms_Options:
			if parent.multiple_selections:
				var answer_count = 0
				for sel in parent.get_data():
					for a in answer_key:
						if a == sel["index"]:
							answer_count += 1
							break
				match _answer_key_criteria:
					AnswerKeyCreteria.ANY_ANSWER:
						valid = answer_count > 0
					AnswerKeyCreteria.ALL_ANSWERS:
						valid = answer_count == answer_key.size()
						
			else:
				for sel in parent.get_data():
					if sel["index"] == options_index:
						valid = true
						break
					
		if parent is gdforms_OptionsGrid:
			var data = parent.get_data()
			
			var selected_indices = []
			for row in data:
				var row_selections = []
				for sel in row["selection"]:
					row_selections.append(sel["index"])
				selected_indices.append(row_selections)
			
			if parent.multiple_selections:
				
				valid = true
				for i in range(selected_indices.size()):
					if i < grid_answer_keys.size():
						var keys_in_selection = 0
						for key in grid_answer_keys[i]:
							if key in selected_indices[i]:
								keys_in_selection += 1
								
						if _answer_key_criteria == AnswerKeyCreteria.ALL_ANSWERS:
							if keys_in_selection != grid_answer_keys[i].size():
								valid = false
								break
						else:
							if keys_in_selection == 0 and grid_answer_keys[i].size() > 0:
								valid = false
								break
			else:
				var valid_count = 0
				for i in range(grid_selections.size()):
					if i < data.size():
						for sel in data[i]["selection"]:
							if sel["index"] == grid_selections[i]:
								valid_count += 1
				valid = valid_count == grid_selections.size()

		if parent is gdforms_TextInput:
			valid = parent.get_data() == text
			
		if parent is gdforms_ValidatedInput:
			valid = parent.is_input_valid() and parent.get_data() == text
			
		if parent is gdforms_FormButton:
			valid = parent.get_data()
		
			
	_set_target_state(valid)

func _on_parent_update(_item_id, _data):
	if _condition_type == Type.SPECIFIC_VALUE:
		_update_state()
	
func _on_parent_interaction():
	if _condition_type == Type.ANY_SELECTION:
		if get_parent() is gdforms_OptionsGrid:
			if get_parent().require_selection_in_every_row:
				var data = get_parent().get_data()
				for row in data:
					if row["selection"].size() == 0:
						_set_target_state(false)
						return
		elif get_parent() is gdforms_ValidatedInput:
			_set_target_state(get_parent().is_input_valid())
			return
			
		_set_target_state(true)
	elif get_parent() is gdforms_ValidatedInput:
		_update_state()
		return

func _on_option_grid_rows_changed(count):
	grid_selections.resize(count)
	grid_answer_keys.resize(count)
	
	for i in range(grid_answer_keys.size()):
		if grid_answer_keys[i] == null:
			grid_answer_keys[i] = PoolIntArray()

func _exit_tree():
	var parent = get_parent()
	if parent is gdforms_OptionsGrid:
		parent.disconnect("rows_changed", self, "_on_option_grid_rows_changed") 

func _enter_tree():
	var parent = get_parent()
	if parent is gdforms_OptionsGrid:
		_on_option_grid_rows_changed(parent.rows.size())
		parent.connect("rows_changed", self, "_on_option_grid_rows_changed")
