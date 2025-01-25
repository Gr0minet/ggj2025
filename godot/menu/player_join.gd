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

@onready var label = $MarginContainer/VBoxContainer/Label
@onready var rich_text_label = $MarginContainer/VBoxContainer/HBoxContainer/RichTextLabel
@onready var progress_bar = $TextureProgressBar
@onready var color_picker = $MarginContainer/VBoxContainer/HBoxContainer/ColorPicker
@onready var color_rectangle = $MarginContainer/VBoxContainer/HBoxContainer/ColorPicker/ColorRect


func _ready() -> void:
	player = Player.new(player_id)
	change_color(0)
	label.text = "Joueur " + str(player_id + 1)
	enter_waiting_state()


func progress_bar_reset() -> void:
	progress_bar.set_value_no_signal(0.0)


func enter_waiting_state() -> void:
	current_state = State.WAITING
	rich_text_label.text = "[center][img]res://assets/xbox_button_color_a_outline.png[/img]
pour rejoindre[/center]"
	color_picker.hide()
	progress_bar_reset()


func enter_joined_state() -> void:
	current_state = State.JOINED
	color_picker.show()
	rich_text_label.text = "[center]Maintiens
[img]res://assets/xbox_button_color_a_outline.png[/img]
pour lancer[/center]"
	progress_bar_reset()


func enter_launching_state() -> void:
	color_picker.hide()
	current_state = State.LAUNCHING


func enter_launched_state() -> void:
	color_picker.hide()
	current_state = State.LAUNCHED
	rich_text_label.text = "[center]Prépare-toi ![/center]"
	progress_bar.set_value_no_signal(100.0)


func change_color(index_change: int) -> void:
	current_color_index = (current_color_index + index_change) % COLORS.size()
	var new_color = COLORS[current_color_index]
	var start_color = Color(new_color, 0.5)
	$TextureProgressBar.texture_progress.gradient.colors = PackedColorArray([start_color, start_color.lightened(0.8)])
	player.color = new_color
	color_rectangle.color = new_color


func _process(delta: float) -> void:
	if current_state == State.LAUNCHING:
		var new_value = progress_bar.value + delta / JOIN_DELAY * 100
		if new_value >= 100:
			enter_launched_state()
			request_game_start_by.emit(player)
		else:
			progress_bar.set_value_no_signal(new_value)


func _unhandled_input(event: InputEvent) -> void:
	if event.device != player_id:
		return
	if event.is_action_pressed("change_color_down") and current_state == State.JOINED:
		change_color(-1)
	if event.is_action_pressed("change_color_up") and current_state == State.JOINED:
		change_color(1)
	if event.is_action_pressed("join_game"):
		if current_state == State.WAITING:
			enter_joined_state()
		else:
			enter_launching_state()
	if event.is_action_released("join_game"):
		if current_state != State.LAUNCHED:
			enter_joined_state()
