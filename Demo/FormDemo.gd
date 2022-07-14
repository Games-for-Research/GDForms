# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This is a simple example that shows how you can use GDForms.
# You should connect to the 'cancel' and 'submit' signals, and provide logic
# for dealing with these events which will always be specific to each application.

extends Control



func _on_Form_cancel():
	# Here, we just show a dialog to confirm with the user.
	$CancelDialog.show()


func _on_Form_submit(id, data):
	# The user has submitted the form. The data comes as a dictionary,
	# which we convert to JSON here. You can, or course, convert or format 
	# the data to whatever your needs may be.
	var json_str = JSON.print(data, "    ")
	
	# We just display the raw data back to the user.
	$SubmitDialog/Container/IdLabel.text = id
	$SubmitDialog/Container/ScrollContainer/DataView.text = json_str
	
	$SubmitDialog.show()


func _on_SubmitDialog_confirmed():
	# Just reload the scene after confirmation. You probably want to do something
	# else here...
	var _err = get_tree().reload_current_scene()


func _on_CancelDialog_confirmed():
	# Just reload the scene after cancellation. You probably want to do something
	# else here also...
	var _err = get_tree().reload_current_scene()
