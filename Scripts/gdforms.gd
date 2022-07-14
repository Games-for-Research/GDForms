# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = preload("../Dock/gdforms_dock.tscn").instance()
	
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
