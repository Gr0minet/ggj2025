extends Node3D


@onready var _hud: HUD = $HUD


func _ready() -> void:
	_hud.start_timer(3)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("full_screen"):
		_swap_fullscreen_mode()
	elif event.is_action_pressed("exit"):
		get_tree().quit()


func _swap_fullscreen_mode():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
