extends Node3D

@export var camera:Camera3D = null

@onready var _hud: HUD = $HUD


#func _ready() -> void:
	## wait 1s before starting, for now
	#await get_tree().create_timer(5.0).timeout
	#start_level()

func start_level() -> void:
	camera.current = true
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
