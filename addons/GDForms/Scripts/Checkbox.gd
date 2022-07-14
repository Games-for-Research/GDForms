# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This class is a wrapper for the standard Godot Checkbox.
# The label can be positioned to the left, right, above and below the button.

tool
extends gdforms_FormItem
class_name gdforms_Checkbox

# This simply relays the 'toggled' signal from the standard Checkbox.
signal toggled(button_pressed)

enum LabelPosition {RIGHT, LEFT, BOTTOM, TOP}

export(String) var text = "" setget set_text, get_text
export(LabelPosition) var label_position = LabelPosition.RIGHT setget set_label_position
export(bool) var pressed setget set_pressed
export(bool) var hide_label = false setget set_hide_label

var group:ButtonGroup setget set_group, get_group


########## Getters / Setters ##########

func set_group(value:ButtonGroup):
	if is_inside_tree():
		$Container/CenterContainer/Button.group = value
	
func get_group():
	if is_inside_tree():
		return $Container/CenterContainer/Button.group
	return null


func set_disabled(value:bool):
	disabled = value
	if is_inside_tree():
		$Container/CenterContainer/Button.disabled = value
	
func get_disabled():
	if is_inside_tree():
		return $Container/CenterContainer/Button.disabled
	return true
	
func set_pressed(value:bool):
	pressed = value
	if is_inside_tree():
		$Container/CenterContainer/Button.pressed = value
	update_form()

func set_text(value:String):
	text = value
	if is_inside_tree():
		$Container/Label.text = value

func get_text():
	if is_inside_tree():
		return $Container/Label.text
	return text


func set_label_position(val):
	label_position = val
	
	if is_inside_tree():
		_layout()

func set_hide_label(val):
	hide_label = bool(val)
	
	if is_inside_tree():
		$Container/Label.visible = not hide_label

func get_button_position() -> Vector2:
	if is_inside_tree():
		return $Container/CenterContainer.rect_position + $Container/CenterContainer.rect_size * 0.5
	return Vector2.ZERO
	
func get_data():
	return pressed
	

########## Utilities ##########

func _layout():
	
	if label_position == LabelPosition.LEFT or label_position == LabelPosition.TOP:
		$Container.move_child($Container/Label, 0)
	else:
		$Container.move_child($Container/CenterContainer, 0)
		
	if label_position == LabelPosition.LEFT or label_position == LabelPosition.RIGHT:
		$Container.columns = 2
		$Container/CenterContainer.size_flags_horizontal = SIZE_EXPAND
	else:
		$Container.columns = 1
		
		
	if label_position == LabelPosition.LEFT:
		$Container/Label.align = Label.ALIGN_RIGHT
		$Container/Label.size_flags_horizontal = SIZE_FILL
		$Container/CenterContainer.size_flags_horizontal = SIZE_FILL
	elif label_position == LabelPosition.RIGHT:
		$Container/Label.align = Label.ALIGN_LEFT
		$Container/Label.size_flags_horizontal = SIZE_EXPAND_FILL
		$Container/CenterContainer.size_flags_horizontal = SIZE_FILL
	else:
		$Container/Label.align = Label.ALIGN_CENTER
		$Container/Label.size_flags_horizontal = SIZE_EXPAND_FILL
		$Container/CenterContainer.size_flags_horizontal = SIZE_EXPAND_FILL


######### Lifecycle ##########

func _ready():
	_layout()
	

func _enter_tree():
	_layout()


######### Callbacks ##########

func _on_Button_toggled(button_pressed:bool):
	set_pressed(button_pressed)
	emit_signal("toggled", button_pressed)
	
	emit_signal("interaction")
