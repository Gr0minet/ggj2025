extends Control

signal request_game_start(players: Array[Player])

@export var player_join_parent: Control = null
@onready var exit_progress_bar = $KeysVBox/ExitHBox/Control/ExitProgressBar
var exiting = false
const EXIT_DELAY = 1.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in player_join_parent.get_children():
		child.request_game_start_by.connect(_on_request_game_start_by)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if exiting:
		var new_value = exit_progress_bar.value + delta / EXIT_DELAY * 100
		if new_value >= 100:
			get_tree().quit()
		else:
			exit_progress_bar.set_value_no_signal(new_value)


func _on_request_game_start_by(player: Player) -> void:
	var players: Array[Player] = [player]
	for child in player_join_parent.get_children():
		if child.current_state != child.State.WAITING and child.player_id != player.id:
			players.append(child.player)
			child.enter_launched_state()
	request_game_start.emit(players)


func _swap_fullscreen_mode():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("show_credits"):
		$Credits.show()
	if event.is_action_pressed("exit"):
		exiting = true
	if event.is_action_released("exit"):
		exiting = false
		exit_progress_bar.set_value_no_signal(0.0)
	if event.is_action_pressed("full_screen"):
		_swap_fullscreen_mode()
