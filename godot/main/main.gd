extends Node3D

@export var camera:Camera3D = null
@export var players_parent_node:PlayerSpawns = null
@export var bubble_scene:PackedScene = null

@onready var _hud: HUD = $HUD


#func _ready() -> void:
	## wait 1s before starting, for now
	#await get_tree().create_timer(5.0).timeout
	#start_level()

func start_level(players:Array[Player]) -> void:
	_clear_players()
	_init_players(players)
	
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

func _clear_players() -> void:
	for n in players_parent_node.get_children():
		players_parent_node.remove_child(n)
		n.queue_free() 

func _init_players(players:Array[Player]) -> void:
	for p in players:
		var spawn_pos:Vector3 = players_parent_node.get_and_lock_spawn()
		
		var bubble:Bubble = bubble_scene.instantiate()
		players_parent_node.add_child(bubble)
		bubble.global_position = spawn_pos
