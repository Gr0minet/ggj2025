extends Control

signal request_game_start(players: Array[Player], match_length: int)

@export var player_join_parent: Control = null
@onready var exit_progress_bar = $KeysMarginContainer/KeysVBox/ExitHBox/Control/ExitProgressBar
@onready var match_settings_vbox = $MarginContainer/MatchSettingsVBox

var match_length_scene = preload("res://menu/match_length_panel_container.tscn")
var match_length_node: Control = null

const LENGTHS = [1, 2, 3, 4, 5, 10, 20, -1]

var current_length_index = 2
var players_joined = {}

var exiting = false
const EXIT_DELAY = 1.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in player_join_parent.get_children():
		child.request_game_start_by.connect(_on_request_game_start_by)
		child.player_joined.connect(_on_player_joined)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if exiting:
		var new_value = exit_progress_bar.value + delta / EXIT_DELAY * 100
		if new_value >= 100:
			get_tree().quit()
		else:
			exit_progress_bar.set_value_no_signal(new_value)


func _on_player_joined(player: Player) -> void:
	players_joined[player] = null
	if players_joined.size() == 2 and match_length_node == null:
		match_length_node = match_length_scene.instantiate()
		match_settings_vbox.add_child(match_length_node)
		match_settings_vbox.move_child(match_length_node, 0)
		match_length_node.match_length = LENGTHS[current_length_index]
		match_length_node.show()

func _on_request_game_start_by(player: Player) -> void:
	var players: Array[Player] = [player]
	for child in player_join_parent.get_children():
		if child.current_state != child.State.WAITING and child.player_id != player.id:
			players.append(child.player)
			child.enter_launched_state()
	request_game_start.emit(players, LENGTHS[current_length_index])


func _swap_fullscreen_mode():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func shift_match_length(shift: int) -> void:
	current_length_index = (current_length_index + shift) % LENGTHS.size()
	match_length_node.match_length = LENGTHS[current_length_index]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_credits"):
		$Credits.show()
	if event.is_action_pressed("change_match_length_right") and match_length_node != null:
		shift_match_length(1)
	if event.is_action_pressed("change_match_length_left") and match_length_node != null:
		shift_match_length(-1)
	if event.is_action_pressed("exit"):
		exiting = true
	if event.is_action_released("exit"):
		exiting = false
		exit_progress_bar.set_value_no_signal(0.0)
	if event.is_action_pressed("full_screen"):
		_swap_fullscreen_mode()
