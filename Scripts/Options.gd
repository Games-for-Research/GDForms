# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This class implements a collection of Checkbox items that function as a single
# item. Multiple selections, as well as single-selection radio buttons are supported.
# The checkboxes can be arranged either vertically or horizontally.
#
# The number of checkboxes/radio buttons is set by changing the size of the 
# 'Labels' array.s
#
# A line can be drawn in the background, between the first and last checkbox.
# To control the color and width of the line, use the 'line_width' and 'line_color'
# constants in the UI theme. See default_forms_theme in the Themes folder for an
# example of how this is done.  

tool
extends gdforms_FormItem
class_name gdforms_Options

# This signal is sent whenever the selection changes. Even in single-selection
# mode, selections will always be an array containing Dictionary entries:
#
# [{"index":2, "label":"Banana"}, {"index":3, "label":"Citrus"}]
#
# The data sent to FormItem's update_form signal is formatted in the same way.
signal selection(selections)

const radio_button_scene = preload("../Scenes/Checkbox.tscn")

enum Direction {HORIZONTAL, VERTICAL}
enum LabelPosition {RIGHT, LEFT, BOTTOM, TOP}

export(bool) var multiple_selections = true setget set_multiple_selections
export(int) var start_index = 1
export(Direction) var direction = Direction.VERTICAL setget set_direction
export(LabelPosition) var label_position = LabelPosition.RIGHT setget set_label_position
export(bool) var draw_line = false setget set_draw_line
export(bool) var hide_labels = false setget set_hide_labels
export(Array, String) var labels = [] setget set_labels

var button_group:ButtonGroup = null

########## Setters ##########

func set_disabled(val):
	disabled = bool(val)
	
	if not is_inside_tree():
		yield(self, "ready")
	
	for b in _get_buttons():
		b.disabled = disabled

func set_label_position(val):
	label_position = val
	
	if not is_inside_tree():
		yield(self, "ready")
	
	for b in _get_buttons():
		b.label_position = val
		
	update()
		
func set_multiple_selections(val):
	multiple_selections = val
	
	if not multiple_selections and button_group == null:
		button_group = ButtonGroup.new()
		
	if not is_inside_tree():
		yield(self, "ready")
	
	for b in _get_buttons():
		if multiple_selections:
			b.group = null
		else:
			b.group = button_group
			
	update()
		
func set_direction(val):
	direction = val
	
	if not is_inside_tree():
		yield(self, "ready")
	
	if direction == Direction.HORIZONTAL:
		$Container.columns =int(max(1, labels.size())) 
	else:
		$Container.columns = 1
	
	# Force the GridContainer to recalculate its size.
	$Container.rect_size = Vector2.ZERO
		
	update()
	
func set_draw_line(val):
	draw_line = val
	
	if not is_inside_tree():
		yield(self, "ready")
	
	update()
	
func set_hide_labels(val):
	hide_labels = bool(val)
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_update_labels()
	
func set_labels(value:Array) :
	labels = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_update_labels()

	update()
	

########## Utilities ##########

func _get_buttons():
	var buttons = []
	
	if is_inside_tree():
		for child in $Container.get_children():
			if child is gdforms_Checkbox:
				buttons.append(child)
	return buttons

func _update_labels():
	if not is_inside_tree():
		return
		
	var buttons = _get_buttons()
	
	var i = 0
	while i < labels.size():
		while i >= buttons.size():
			var new_button = radio_button_scene.instance()
			new_button.size_flags_horizontal = SIZE_EXPAND_FILL
			new_button.size_flags_vertical = SIZE_EXPAND_FILL
			new_button.label_position = label_position
			$Container.add_child(new_button)
			new_button.connect("toggled", self, "_on_button_toggled")
			buttons.append(new_button)
			if not multiple_selections:
				new_button.group = button_group
		buttons[i].text = labels[i]
		buttons[i].hide_label = hide_labels
		i += 1
		
	while i < buttons.size():
		buttons[i].queue_free()
		i += 1
		
	if direction == Direction.HORIZONTAL:
		$Container.columns = int(max(1, labels.size()))

func get_selections():
	var selection = []
	if is_inside_tree():
		var buttons = _get_buttons()
		for i in range(buttons.size()):
			if buttons[i].pressed:
				selection.append({"index": i + start_index, "label": buttons[i].text})
	return selection
	
func get_data():
	return get_selections()

######### Lifecycle ##########

func _ready():
	# Force a redraw whenever the grid container's children need sorting.
	var _err = $Container.connect("sort_children", self, "update")
	
	_update_labels()
	
func _draw():
	if draw_line:
		var buttons = _get_buttons()
		if buttons.size() > 1:
			var width = 2
			var color = Color(0.15, 0.15, 0.15)

			if has_constant("line_width", "gdforms_Options"):
				width = get_constant("line_width", "gdforms_Options")
			if has_color("line_color", "gdforms_Options"):
				color = get_color("line_color", "gdforms_Options")
				

			var from = buttons.front().get_button_position() + buttons.front().rect_position
			var to = buttons.back().get_button_position() + buttons.back().rect_position
			draw_line(from, to, color, width)
			
func _notification(what):
	match what:
		NOTIFICATION_THEME_CHANGED:
			if is_inside_tree():
				if has_constant("separation", "gdforms_Options"):
					var separation = get_constant("separation", "gdforms_Options")
					$Container.add_constant_override("hseparation", separation)
					$Container.add_constant_override("vseparation", separation)


######### Callbacks ##########

func _on_button_toggled(_pressed:bool):
	if _pressed or multiple_selections:
		emit_signal("selection", get_selections())
		emit_signal("interaction")
		update_form()
