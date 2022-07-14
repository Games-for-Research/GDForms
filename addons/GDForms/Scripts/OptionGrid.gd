# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends gdforms_FormItem
class_name gdforms_OptionsGrid

signal rows_changed(count)

const cell_scene = preload("../Scenes/Utilities/OptionGridCell.tscn")
const header_scene = preload("../Scenes/Utilities/OptionGridHeader.tscn")

export(bool) var multiple_selections = true setget set_multiple_selections
export(bool) var require_selection_in_every_row = true
export(int) var start_index = 1
export(bool) var draw_line = false setget set_draw_line
export(Array, String) var columns = [] setget set_columns
export(Array, String) var rows = [] setget set_rows

var button_groups = []
var row_checkboxes = []

########## Setters ##########

func set_multiple_selections(val):
	multiple_selections = val
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_update_grid()
	
func set_rows(val):
	rows = val
	
	emit_signal("rows_changed", rows.size())
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_update_grid()
	
func set_columns(val):
	columns = val
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_update_grid()

func set_disabled(val:bool):
	.set_disabled(val)
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_update_grid()
	
func set_draw_line(val):
	draw_line = val
	
	if not is_inside_tree():
		yield(self, "ready")
	
	update()
	
########## Utilities ##########

func _update_labels(count):
	var children = []
	if is_inside_tree():
		for child in $Container.get_children():
			if child is Container:
				var n = child.get_node_or_null("Label")
				if n != null:
					children.append(child)
	
	while children.size() < count:
		var child = header_scene.instance()
		$Container.add_child(child)
		children.append(child)
		child.set_owner($Container)
		child.size_flags_horizontal = SIZE_EXPAND_FILL
		child.size_flags_vertical = SIZE_EXPAND_FILL
	while children.size() > count:
		var child = children.pop_back()
		child.queue_free()
	return children
	
func _update_cells(count):
	var children = []
	if is_inside_tree():
		for child in $Container.get_children():
			if child is Container:
				var n = child.get_node_or_null("Center/CheckBox")
				if n != null:
					children.append(child)
	while children.size() < count:
		var child = cell_scene.instance()
		$Container.add_child(child)
		children.append(child)
		child.set_owner($Container)
		child.size_flags_horizontal = SIZE_EXPAND_FILL
		child.size_flags_vertical = SIZE_EXPAND_FILL
	while children.size() > count:
		var child = children.pop_back()
		child.queue_free()
	return children

func _get_checkbox(container):
	return container.get_node_or_null("Center/CheckBox")

func _update_grid():
	if not is_inside_tree():
		return
		
	if not multiple_selections:
		while button_groups.size() < rows.size():
			var group = ButtonGroup.new()
			button_groups.append(group)
		button_groups.resize(rows.size())
	
	var label_count = columns.size() + rows.size()
	var checkbox_count = columns.size() * rows.size()
	
	$Container.columns = columns.size() + 1
	
	row_checkboxes.clear()
	
	var label_containers = _update_labels(label_count)
	var cell_containers = _update_cells(checkbox_count)
	
	var label_ndx = 0
	var box_ndx = 0
	var index = 1
	
	# Header
	for col in range(columns.size()):
		$Container.move_child(label_containers[label_ndx], index)
		var label = label_containers[label_ndx].get_node("Label")
		label.text = columns[col]
		label.align = HALIGN_CENTER
		label.valign = VALIGN_BOTTOM
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.size_flags_vertical = SIZE_FILL
		
		if has_constant("header_padding_top", "gdforms_OptionGrid"):
			label_containers[label_ndx].add_constant_override("margin_top", get_constant("header_padding_top", "gdforms_OptionGrid"))	
		if has_constant("header_padding_bottom", "gdforms_OptionGrid"):
			label_containers[label_ndx].add_constant_override("margin_bottom", get_constant("header_padding_bottom", "gdforms_OptionGrid"))
			
		label_ndx += 1
		index += 1
				
	for row in range(rows.size()):
		row_checkboxes.append([])
		
		# Row header
		$Container.move_child(label_containers[label_ndx], index)
		var label = label_containers[label_ndx].get_node("Label")
		label.text = rows[row]
		label.align = HALIGN_RIGHT
		label.valign = VALIGN_CENTER
		label.size_flags_horizontal = SIZE_FILL
		label.size_flags_vertical = SIZE_EXPAND_FILL
		
		if has_constant("header_padding_left", "gdforms_OptionGrid"):
			label_containers[label_ndx].add_constant_override("margin_left", get_constant("header_padding_left", "gdforms_OptionGrid"))	
		if has_constant("header_padding_right", "gdforms_OptionGrid"):
			label_containers[label_ndx].add_constant_override("margin_right", get_constant("header_padding_right", "gdforms_OptionGrid"))
		
		index += 1
		label_ndx += 1
		
		for col in range(columns.size()):
			$Container.move_child(cell_containers[box_ndx], index)
			
			# Update the theme overrides
			if has_constant("row_padding_bottom", "gdforms_OptionGrid"):
				cell_containers[box_ndx].add_constant_override("margin_bottom", get_constant("row_padding_bottom", "gdforms_OptionGrid"))	
			if has_constant("row_padding_top", "gdforms_OptionGrid"):
				cell_containers[box_ndx].add_constant_override("margin_top", get_constant("row_padding_top", "gdforms_OptionGrid"))	
			if has_constant("column_padding_left", "gdforms_OptionGrid"):
				cell_containers[box_ndx].add_constant_override("margin_left", get_constant("column_padding_left", "gdforms_OptionGrid"))	
			if has_constant("column_padding_left", "gdforms_OptionGrid"):
				cell_containers[box_ndx].add_constant_override("margin_right", get_constant("column_padding_left", "gdforms_OptionGrid"))		
			
			var checkbox = _get_checkbox(cell_containers[box_ndx])
			if not multiple_selections:
				checkbox.group = button_groups[row]
			else:
				checkbox.group = null
			checkbox.disabled = disabled
			
			if checkbox.is_connected("toggled", self, "_on_checkbox_toggle"):
				checkbox.disconnect("toggled", self, "_on_checkbox_toggle")
			var err = checkbox.connect("toggled", self, "_on_checkbox_toggle", [row, col])
			if OK != err:
				push_warning("Could not connect checkbox signal.")
			
			row_checkboxes.back().append(checkbox)
			
			box_ndx += 1
			index += 1
			
	update()

func get_data():
	var data = []
	for i in range(rows.size()):
		data.append({"label": rows[i], "selection":[]})
		if i < row_checkboxes.size():
			for j in range(int(min(columns.size(), row_checkboxes[i].size()))):
				if row_checkboxes[i][j].pressed:
					data.back()["selection"].append({"index": j + start_index, "label":columns[j]})
	return data	

######### Lifecycle ##########

func _ready():
	# Force a redraw whenever the grid container's children need sorting.
	$Container.connect("sort_children", self, "update")
	$Container.connect("item_rect_changed", self, "update")
	
	_update_grid()
	
func _draw():
	if draw_line:
		for row in row_checkboxes:
			if row.size() > 1:
				var from = row.front().rect_global_position + row.front().rect_size * 0.5
				var to = row.back().rect_global_position + row.back().rect_size * 0.5
				
				var mat = get_global_transform().affine_inverse()
				
				draw_set_transform_matrix(mat)

				var width = 2
				var color = Color(0.15, 0.15, 0.15)

				if has_constant("line_width", "gdforms_OptionGrid"):
					width = get_constant("line_width", "gdforms_OptionGrid")
				if has_color("line_color", "gdforms_OptionGrid"):
					color = get_color("line_color", "gdforms_OptionGrid")
								
				draw_line(from, to, color, width)
				
func _notification(what):
	match what:
		NOTIFICATION_THEME_CHANGED:
			if has_constant("vseparation", "gdforms_OptionGrid"):
				$Container.add_constant_override("vseparation", get_constant("vseparation", "gdforms_OptionGrid"))
			if has_constant("hseparation", "gdforms_OptionGrid"):
				$Container.add_constant_override("hseparation", get_constant("hseparation", "gdforms_OptionGrid"))
				
			_update_grid()
		NOTIFICATION_SORT_CHILDREN:
			update()
	
########## Callbacks ##########

func _on_checkbox_toggle(_pressed, _row, _column):
	update_form()
	emit_signal("interaction")
