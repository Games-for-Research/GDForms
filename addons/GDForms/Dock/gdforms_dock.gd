# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Control

const OptionsScene = preload("res://addons/GDForms/Scenes/Options.tscn")
const ScaleScene = preload("res://addons/GDForms/Scenes/Scale.tscn")
const OptionGridScene = preload("res://addons/GDForms/Scenes/OptionGrid.tscn")
const TextInputScene = preload("res://addons/GDForms/Scenes/TextInput.tscn")
const ValidatedInputScene = preload("res://addons/GDForms/Scenes/ValidatedInput.tscn")
const CheckboxScene = preload("res://addons/GDForms/Scenes/Checkbox.tscn")
const GenericButtonScene = preload("res://addons/GDForms/Scenes/FormButton.tscn")
const CancelButtonScene = preload("res://addons/GDForms/Scenes/CancelButton.tscn")
const SubmitButtonScene = preload("res://addons/GDForms/Scenes/SubmitButton.tscn")
const NextButtonScene = preload("res://addons/GDForms/Scenes/NextButton.tscn")
const BackButtonScene = preload("res://addons/GDForms/Scenes/BackButton.tscn")
const BranchScene = preload("res://addons/GDForms/Scenes/Branch.tscn")

var selected_node = null

func _ready():
	var plugin = EditorPlugin.new()
	var eds = plugin.get_editor_interface().get_selection().connect("selection_changed", self, "_on_user_selection_changed")

	$VBoxContainer/FormEdit/AddSection/ContainerType.clear()
	$VBoxContainer/FormEdit/AddSection/ContainerType.add_item("PanelContainer")
	$VBoxContainer/FormEdit/AddSection/ContainerType.add_item("MarginContainer")
	$VBoxContainer/FormEdit/AddSection/ContainerType.add_item("VBoxContainer")
	$VBoxContainer/FormEdit/AddSection/ContainerType.add_item("HBoxContainer")
	
	$VBoxContainer/FormEdit/PageSelector.get_popup().connect("about_to_show", self, "_on_about_to_show_page_list")

func _get_user_selection():
	var plugin = EditorPlugin.new()
	var eds = plugin.get_editor_interface().get_selection()
	var selected = eds.get_selected_nodes()
	if selected.empty():
		return plugin.get_editor_interface().get_edited_scene_root()
	else:
		return selected.front()

func _find_in_parents(type, node):
	var p = node
	while not p == null:
		if p is type:
			return p
		p = p.get_parent()
		
	return null
	
func _set_owner_recursive(node, owner):
	node.owner = owner
	for child in node.get_children():
		_set_owner_recursive(child, owner)
		
func _on_user_selection_changed():
	selected_node = _get_user_selection()
	
	# We shouldn't allow nested forms
	var form = _find_in_parents(gdforms_Form, selected_node)
	$VBoxContainer/CreateForm.visible = form == null
	
	# Show the form editor
	$VBoxContainer/FormEdit.visible = form != null
	
	if form != null:
		var current_page = form.get_current_page()
		if current_page != null:
			$VBoxContainer/FormEdit/AddSectionLabels/AddSectionParent.text = current_page.name
			
	# Don't add a branch if not a FormItem
	$VBoxContainer/FormEdit/AddFormElements/AddBranch.visible = selected_node is gdforms_FormItem
	
	# Don't nest form items
	var parent_item = _find_in_parents(gdforms_FormItem, selected_node)
	$VBoxContainer/FormEdit/AddFormElements/AddFormItems.visible = parent_item == null

func _add_page(form, title="Form Page"):
	var page = load("res://addons/GDForms/Scenes/FormPage.tscn").instance()
	page.name = title
	form.add_child(page)
	page.set_owner(get_tree().edited_scene_root)
	page.rect_size = form.rect_size

func _on_create_new_form():
	if selected_node != null:
		# Add the form
		var form = load("res://addons/GDForms/Scenes/Form.tscn").instance()
		form.form_id = $VBoxContainer/CreateForm/FormId.text
		selected_node.add_child(form)
		form.set_owner(get_tree().edited_scene_root)
		
		# Add a default page
		_add_page(form)


func _on_add_new_page():
	var form = _find_in_parents(gdforms_Form, selected_node)
	if form != null:
		var title = $VBoxContainer/FormEdit/AddPage/PageTitle.text
		if title == "":
			_add_page(form)
		else:
			_add_page(form, title)


func _on_add_section():
	var section_parent = _find_in_parents(gdforms_FormPage, selected_node)
	if section_parent == null:
		var form = _find_in_parents(gdforms_Form, selected_node)
		if form == null:
			return
		var current_page = form.get_current_page()
		if current_page == null:
			return
		section_parent = current_page
	
	var container = null
	var selection = $VBoxContainer/FormEdit/AddSection/ContainerType.selected
	var selection_label = $VBoxContainer/FormEdit/AddSection/ContainerType.get_item_text(selection)

	match selection_label:
		"PanelContainer":
			container = PanelContainer.new()
		"MarginContainer":
			container = MarginContainer.new()
		"VBoxContainer":
			container = VBoxContainer.new()
		"HBoxContainer":
			container = HBoxContainer.new()
			
	if container != null:
		section_parent.add_child(container)
		container.set_owner(get_tree().edited_scene_root)
		var section_title = $VBoxContainer/FormEdit/AddSection/SectionTitle.text
		if section_title != "":
			container.name = section_title
			$VBoxContainer/FormEdit/AddSection/SectionTitle.text = ""


func _on_page_enter_tree(page):
	pass
	
func _on_page_exit_tree(page):
	pass
	
func _on_about_to_show_page_list():
	if selected_node != null:
		var form = _find_in_parents(gdforms_Form, selected_node)
		if form != null:
			var pages = form.get_pages()
			var selection  = $VBoxContainer/FormEdit/PageSelector.selected
			var selection_label = ""
			if selection >= 0:
				selection_label = $VBoxContainer/FormEdit/PageSelector.get_item_text(selection)
			var i = 0
			$VBoxContainer/FormEdit/PageSelector.clear()
			for p in pages:
				$VBoxContainer/FormEdit/PageSelector.add_item(p.name)
				if p.name == selection_label:
					selection = i
				i += 1
			$VBoxContainer/FormEdit/PageSelector.selected = selection

func _on_show_page(index):
	var form = _find_in_parents(gdforms_Form, selected_node)
	if form != null:
		var selection  = $VBoxContainer/FormEdit/PageSelector.selected
		form.set_current_page(selection)
		var current_page = form.get_current_page()
		if current_page != null:
			$VBoxContainer/FormEdit/AddSectionLabels/AddSectionParent.text = current_page.name

func _add_form_element_of_type(res):
	if selected_node != null:
		var new_element = res.instance()
		if new_element is gdforms_FormItem:
			new_element.item_id = $VBoxContainer/FormEdit/AddFormElements/ItemId.text
		selected_node.add_child(new_element)
		new_element.set_owner(get_tree().edited_scene_root)
		$VBoxContainer/FormEdit/AddFormElements/ItemId.text = ""

func _on_AddBranch_pressed():
	_add_form_element_of_type(BranchScene)


func _on_AddOptions_pressed():
	_add_form_element_of_type(OptionsScene)


func _on_AddScale_pressed():
	_add_form_element_of_type(ScaleScene)


func _on_AddOptionGrid_pressed():
	_add_form_element_of_type(OptionGridScene)


func _on_AddTextInput_pressed():
	_add_form_element_of_type(TextInputScene)


func _on_AddValidatedInput_pressed():
	_add_form_element_of_type(ValidatedInputScene)


func _on_AddCheckbox_pressed():
	_add_form_element_of_type(CheckboxScene)


func _on_AddGenericButton_pressed():
	_add_form_element_of_type(GenericButtonScene)


func _on_AddCancelButton_pressed():
	_add_form_element_of_type(CancelButtonScene)


func _on_AddSubmitButton_pressed():
	_add_form_element_of_type(SubmitButtonScene)


func _on_AddNextButton_pressed():
	_add_form_element_of_type(NextButtonScene)


func _on_AddPreviousButton_pressed():
	_add_form_element_of_type(BackButtonScene)
