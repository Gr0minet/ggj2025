@tool
extends EditorPlugin


const TRANSLATE_SNAP: Array[float] = [0.05, 0.1, 0.2, 0.5, 1.0, 2.0, 4.0]
const ROTATION_SNAP: Array[float] = [5, 10, 15, 30, 45, 90]
const SCALE_SNAP: Array[float] = [10, 50, 100]

const ACTION_KEY_DICT: Dictionary = {
	&"decrease_translate_snap": KEY_1,
	&"increase_translate_snap": KEY_2,
	&"decrease_rotation_snap": KEY_3,
	&"increase_rotation_snap": KEY_4,
	&"decrease_scale_snap": KEY_5,
	&"increase_scale_snap": KEY_6,
	&"snap_to_grid": KEY_N,
}

var translate_snap_idx: int = len(TRANSLATE_SNAP) - 1
var rotation_snap_idx: int = len(ROTATION_SNAP) - 1
var scale_snap_idx: int = len(SCALE_SNAP) - 1
var current_node_3d: Node3D = null

var snap_to_grid_button: Button = Button.new()
var translate_snap_label: Label = Label.new()
var rotation_snap_label: Label = Label.new()
var scale_snap_label: Label = Label.new()

var translate_snap_line_edit: LineEdit = null
var rotation_snap_line_edit: LineEdit = null
var scale_snap_line_edit: LineEdit = null

var confirmation_dialog: ConfirmationDialog = null


func _enter_tree() -> void:
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selected_nodes.size() == 1 and selected_nodes[0] is Node3D:
		current_node_3d = selected_nodes[0]
	
	_initialize_shortcuts()
	_initialize_snap_to_grid_button_theme()
	_retrieve_snap_line_edit_from_godot_UI()
	_update_snap()
	
	var plugin_controls: Array[Control] = [
		translate_snap_label,
		rotation_snap_label,
		scale_snap_label,
		snap_to_grid_button,
	]
	for control: Control in plugin_controls:
		add_control_to_container(
			CustomControlContainer.CONTAINER_SPATIAL_EDITOR_MENU,
			control
		)
	
	
func _exit_tree() -> void:
	var plugin_controls: Array[Control] = [
		translate_snap_label,
		rotation_snap_label,
		scale_snap_label,
		snap_to_grid_button,
	]
	for control: Control in plugin_controls:
		remove_control_from_container(CustomControlContainer.CONTAINER_SPATIAL_EDITOR_MENU, control)
	for action: String in ACTION_KEY_DICT:
		if InputMap.has_action(action):
			InputMap.erase_action(action)


func _handles(object: Object) -> bool:
	if object is Node3D:
		current_node_3d = object as Node3D
		snap_to_grid_button.visible = true
	else:
		snap_to_grid_button.visible = false
		current_node_3d = null
	return false


func _initialize_snap_to_grid_button_theme() -> void:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	snap_to_grid_button.add_theme_stylebox_override("normal", style_box)
	snap_to_grid_button.pressed.connect(_snap_to_grid)
	snap_to_grid_button.text = "Snap To Grid"
	snap_to_grid_button.tooltip_text = (
		"Snap to the nearest grid point based on the grid translate snap"
		+ " (" + OS.get_keycode_string(ACTION_KEY_DICT[&"snap_to_grid"]) + ")"
	)


func _initialize_shortcuts() -> void:
	for action: String in ACTION_KEY_DICT:
		if InputMap.has_action(action):
			continue
		var event_key = InputEventKey.new()
		event_key.physical_keycode = ACTION_KEY_DICT[action]
		InputMap.add_action(action)
		InputMap.action_add_event(action, event_key)


func _retrieve_snap_line_edit_from_godot_UI() -> void:
	for label: Label in _get_all_label_children(EditorInterface.get_base_control()):
		if label.text.contains("Translate Snap:"):
			var vboxcontainer: VBoxContainer = label.get_parent()
			translate_snap_line_edit = vboxcontainer.get_child(1).get_child(0)
			rotation_snap_line_edit = vboxcontainer.get_child(3).get_child(0)
			scale_snap_line_edit = vboxcontainer.get_child(5).get_child(0)
			confirmation_dialog = vboxcontainer.get_parent()
			break


func _get_all_label_children(node: Node) -> Array[Node]:
	var all_label_children: Array[Node] = []
	if node.get_child_count() == 0 and node is Label:
		return [node]
	else:
		for child: Node in node.get_children():
			all_label_children += _get_all_label_children(child)
		return all_label_children


func _unhandled_input(event: InputEvent) -> void:
	var is_3d_viewport_visible: bool = EditorInterface.get_editor_main_screen().get_child(1).is_visible()
	if not is_3d_viewport_visible:
		return
	
	if event.is_action_pressed(&"decrease_translate_snap") and translate_snap_idx > 0:
		translate_snap_idx -= 1
		_update_snap()
	elif event.is_action_pressed(&"increase_translate_snap") and translate_snap_idx < len(TRANSLATE_SNAP) - 1:
		translate_snap_idx += 1
		_update_snap()
	elif event.is_action_pressed(&"decrease_rotation_snap") and rotation_snap_idx > 0:
		rotation_snap_idx -= 1
		_update_snap()
	elif event.is_action_pressed(&"increase_rotation_snap") and rotation_snap_idx < len(ROTATION_SNAP) - 1:
		rotation_snap_idx += 1
		_update_snap()
	elif event.is_action_pressed(&"decrease_scale_snap") and scale_snap_idx > 0:
		scale_snap_idx -= 1
		_update_snap()
	elif event.is_action_pressed(&"increase_scale_snap") and scale_snap_idx < len(SCALE_SNAP) - 1:
		scale_snap_idx += 1
		_update_snap()
	elif event.is_action_pressed(&"snap_to_grid") and current_node_3d != null:
		_snap_to_grid()


func _update_snap() -> void:
	translate_snap_line_edit.text = str(TRANSLATE_SNAP[translate_snap_idx])
	rotation_snap_line_edit.text = str(ROTATION_SNAP[rotation_snap_idx])
	scale_snap_line_edit.text = str(SCALE_SNAP[scale_snap_idx])
	confirmation_dialog.confirmed.emit()
	
	translate_snap_label.text = "T: " + str(TRANSLATE_SNAP[translate_snap_idx]) + "m"
	rotation_snap_label.text = "R: " + str(ROTATION_SNAP[rotation_snap_idx]) + "°"
	scale_snap_label.text = "S: " + str(SCALE_SNAP[scale_snap_idx]) + "%"


func _snap_to_grid() -> void:
	var undo_redo = get_undo_redo()
	undo_redo.create_action("Snap to grid")
	undo_redo.add_do_property(
		current_node_3d,
		"position",
		current_node_3d.position.snappedf(TRANSLATE_SNAP[translate_snap_idx])
	)
	undo_redo.add_undo_property(current_node_3d, "position", current_node_3d.position)
	undo_redo.commit_action()
