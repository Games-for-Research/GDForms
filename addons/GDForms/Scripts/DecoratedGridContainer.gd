# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends GridContainer
class_name gdforms_GridContainer

export(int) var header_rows = 0 setget set_header_rows
export(int) var header_columns = 0 setget set_header_columns
export(int) var footer_rows = 0 setget set_footer_rows

func set_header_rows(val:int):
	if val > 0:
		header_rows = int(val)
	else:
		header_rows = 0
	
	update()
	
func set_header_columns(val:int):
	if val > 0:
		header_columns = int(val)
	else:
		header_columns = 0
	
	update()
	
func set_footer_rows(val:int):
	if val > 0:
		footer_rows = int(val)
	else:
		footer_rows = 0
	
	update()
	
func _get_child_controls():
	var controls = []
	for child in get_children():
		if child is Control:
			controls.append(child)
	return controls
	
func _draw():
	if is_inside_tree():
		var hseparation = get_constant("hseparation")
		var vseparation = get_constant("vseparation")

		var separation = Vector2(hseparation, vseparation)

		if has_stylebox("cell_style", "gdforms_GridContainer"):
			var cell_style = get_stylebox("cell_style", "gdforms_GridContainer")
			var row_header_style = get_stylebox("row_header_style", "gdforms_GridContainer") if has_stylebox("row_header_style", "gdforms_GridContainer") else cell_style
			var column_header_style = get_stylebox("column_header_style", "gdforms_GridContainer") if has_stylebox("column_header_style", "gdforms_GridContainer") else cell_style
			var footer_style = get_stylebox("footer_style", "gdforms_GridContainer") if has_stylebox("footer_style", "gdforms_GridContainer") else cell_style

			var rid = get_canvas_item()

			var controls = _get_child_controls()
			var rows = int(ceil(float(controls.size()) / columns))

			for i in range(controls.size()):
				var child = controls[i]
				var row = int(float(i) / columns)
				var col = i % columns
				var rect = Rect2(child.rect_position, child.rect_size + separation)

				if row < header_rows:
					row_header_style.draw(rid, rect)
				elif row >= rows - footer_rows:
					footer_style.draw(rid, rect)
				elif col < header_columns:
					column_header_style.draw(rid, rect)
				else:
					cell_style.draw(rid, rect)


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		update()
