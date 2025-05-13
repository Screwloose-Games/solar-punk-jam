## ResourceAutoEditor.gd
#@tool
extends ScrollContainer
class_name ResourceAutoEditor     #  add as a custom type if you like

## ──────── Inspector‑exposed settings ────────
@export_file("*.tres", "*.res") var resource_path: String
@export var resource: Resource
@export var label_column_min_width: int = 140

## ──────── Internals ────────
var _resource: Resource                     # loaded instance
var _root_vbox: VBoxContainer               # holds generated rows

# --------------------------------------------------
func _ready() -> void:
	# Make sure we have a container to populate
	_root_vbox = VBoxContainer.new()
	_root_vbox.name = "AutoFields"
	add_child(_root_vbox)
	#if Engine.is_editor_hint():
	_rebuild()                          # initial build when opened in editor

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		# Re‑generate whenever the user changes the resource_path in the Inspector
		_rebuild()

# --------------------------------------------------
func _rebuild() -> void:
	# Clear any previously generated controls
	for child in _root_vbox.get_children():
		child.queue_free()

	if resource_path.is_empty() and !resource:
		return

	#_resource = ResourceLoader.load(resource_path)
	_resource = resource
	if _resource == null:
		push_error("Could not load resource at %s" % resource_path)
		return

	# Iterate over all exported fields
	for info in _resource.get_property_list():
		var usage: int = info.usage
		var res = usage & PROPERTY_USAGE_EDITOR != 0
		if not res:
			continue                        # skip non‑exported / script internals
		_root_vbox.add_child(_make_row(info))

# --------------------------------------------------
func _make_row(info: Dictionary) -> Control:
	# Row = Label + editor control
	var row := HBoxContainer.new()
	row.name = "row_%s" % info.name

	var lbl := Label.new()
	lbl.text = info.name # .humanize()
	lbl.custom_minimum_size.x = label_column_min_width
	row.add_child(lbl)

	var editor = _make_editor_for_type(info.type, _resource.get(info.name))
	editor.name = "editor_%s" % info.name
	row.add_child(editor)

	# one‑shot lambda to keep the resource in sync
	var _commit = func _commit(val):
		_resource.set(info.name, val)
		# Optionally save immediately:
		# ResourceSaver.save(resource_path, _resource)

	match info.type:
		TYPE_STRING:
			editor.text_changed.connect(_commit)
		TYPE_INT, TYPE_FLOAT:
			editor.value_changed.connect(_commit)
		TYPE_BOOL:
			editor.toggled.connect(_commit)

	return row

# --------------------------------------------------
func _make_editor_for_type(t: int, value):
	match t:
		TYPE_STRING:
			var e := LineEdit.new()
			e.text = str(value)
			return e
		TYPE_INT:
			var e := SpinBox.new()
			e.step = 1
			e.value = value
			return e
		TYPE_FLOAT:
			var e := SpinBox.new()
			e.step = 0.01
			e.allow_greater = true
			e.value = value
			return e
		TYPE_BOOL:
			var e := CheckBox.new()
			e.button_pressed = value
			return e
		TYPE_ARRAY:
			return _build_array_editor(value)
		TYPE_DICTIONARY:
			return _build_dict_editor(value)
		TYPE_OBJECT:
			var label := Label.new()
			label.text = "[Object: %s]" % value.get_class()
			return label
		_:
			var label := Label.new()
			label.text = "Unsupported type"
			return label

func _build_array_editor(array: Array) -> Control:
	var vbox := VBoxContainer.new()
	vbox.name = "ArrayEditor"

	for item in array:
		var hbox := HBoxContainer.new()
		var le := LineEdit.new()
		le.text = str(item)
		le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(le)
		vbox.add_child(hbox)

	var add_button := Button.new()
	add_button.text = "Add Item"
	add_button.pressed.connect(func():
		var new_line := LineEdit.new()
		new_line.text = ""
		var hbox := HBoxContainer.new()
		hbox.add_child(new_line)
		vbox.add_child(hbox, vbox.get_child_count() - 1) # before button
	)
	vbox.add_child(add_button)

	return vbox

func _build_dict_editor(dict: Dictionary) -> Control:
	var vbox := VBoxContainer.new()
	vbox.name = "DictionaryEditor"

	for key in dict.keys():
		var hbox := HBoxContainer.new()

		var key_field := LineEdit.new()
		key_field.text = str(key)
		hbox.add_child(key_field)

		var value_field := LineEdit.new()
		value_field.text = str(dict[key])
		value_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(value_field)

		vbox.add_child(hbox)

	var add_button := Button.new()
	add_button.text = "Add Pair"
	add_button.pressed.connect(func():
		var hbox := HBoxContainer.new()
		var key_le := LineEdit.new()
		var val_le := LineEdit.new()
		val_le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(key_le)
		hbox.add_child(val_le)
		vbox.add_child(hbox, vbox.get_child_count() - 1)
	)
	vbox.add_child(add_button)

	return vbox
