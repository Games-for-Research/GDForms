# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This is just a simple Box Container that allows you to split a form
# into multiple pages. The parent Form will recognise its Page children
# and use them when performing navigation.

tool
extends VBoxContainer
class_name gdforms_FormPage

export(int) var index = -1

func _notification(what):
	if what == NOTIFICATION_ENTER_CANVAS or what == NOTIFICATION_MOVED_IN_PARENT :
		var i = 1
		for sibling in get_parent().get_children():
			if sibling == self:
				index = i
				break
			else:
				if sibling.get_class() == get_class():
					i += 1
