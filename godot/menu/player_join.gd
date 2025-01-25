class_name PlayerJoin
extends PanelContainer

signal request_game_start_by(player: Player)


@export var player_id: int

const COLORS = [Color.CADET_BLUE, Color.CHARTREUSE, Color.CORAL, Color.DEEP_PINK]
var current_color_index = 0
const JOIN_DELAY = 1.5

enum State{
	WAITING,
	JOINED,
	LAUNCHING,
	LAUNCHED
}

var current_state: State = State.WAITING

var player: Player = null

@onready var label = $ClipAlphaPatch/MarginContainer/VBoxContainer/Label
@onready var rich_text_label = $ClipAlphaPatch/MarginContainer/VBoxContainer/HBoxContainer/RichTextLabel
@onready var progress_bar = $ClipAlphaPatch/TextureProgressBar
@onready var color_picker = $ClipAlphaPatch/MarginContainer/VBoxContainer/HBoxContainer/ColorPicker
@onready var color_rectangle = $ClipAlphaPatch/MarginContainer/VBoxContainer/HBoxContainer/ColorPicker/ColorRect


func _ready() -> void:
	player = Player.new(player_id)
	# We don't call set_color here because for some reason TexturedProgressBar
	# isn't initialized yet, so we defer the call to enter_joined_state
	current_color_index = player_id
	label.text = "Player " + str(player_id + 1)
	enter_waiting_state()


func progress_bar_reset() -> void:
	progress_bar.set_value_no_signal(0.0)


func enter_waiting_state() -> void:
	current_state = State.WAITING
	rich_text_label.text = "[center]Press
[img]res://assets/xbox_button_color_a_outline.png[/img]
to join[/center]"
	color_picker.hide()
	progress_bar_reset()


func enter_joined_state() -> void:
	set_color(current_color_index)
	current_state = State.JOINED
	color_picker.show()
	rich_text_label.text = "[center]Keep
[img]res://assets/xbox_button_color_a_outline.png[/img]
pressed
to start[/center]"
	progress_bar_reset()


func enter_launching_state() -> void:
	color_picker.hide()
	current_state = State.LAUNCHING


func enter_launched_state() -> void:
	color_picker.hide()
	current_state = State.LAUNCHED
	rich_text_label.text = "[center]Get ready![/center]"
	progress_bar.set_value_no_signal(100.0)


func set_color(index: int) -> void:
	current_color_index = index
	var new_color = COLORS[index]
	var start_color = Color(new_color, 0.5)
	progress_bar.texture_progress.gradient.colors = PackedColorArray([start_color, start_color.lightened(0.8)])
	player.color = new_color
	color_rectangle.color = new_color


func previous_color() -> void:
	set_color((current_color_index - 1) % COLORS.size())


func next_color() -> void:
	set_color((current_color_index + 1) % COLORS.size())


func _process(delta: float) -> void:
	if current_state == State.LAUNCHING:
		var new_value = progress_bar.value + delta / JOIN_DELAY * 100
		if new_value >= 100:
			enter_launched_state()
			request_game_start_by.emit(player)
		else:
			progress_bar.set_value_no_signal(new_value)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.device != player_id:
		return
	if event.is_action_pressed("change_color_down") and current_state == State.JOINED:
		previous_color()
	if event.is_action_pressed("change_color_up") and current_state == State.JOINED:
		next_color()
	if event.is_action_pressed("join_game"):
		if current_state == State.WAITING:
			enter_joined_state()
		else:
			enter_launching_state()
	if event.is_action_released("join_game"):
		if current_state != State.LAUNCHED:
			enter_joined_state()
