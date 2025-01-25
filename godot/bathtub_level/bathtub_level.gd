extends Node3D

@export var players_parent_node:Node3D = null
@export var player_spawns:PlayerSpawns = null
@export var bubble_scene:PackedScene = null

@onready var _hud: HUD = $HUD


func _ready() -> void:
	allow_player_input(false)

func start_level(players:Array[Player]) -> void:
	AudioManager.mute_music2(false)
	
	_clear_players()
	_init_players(players)
	
	allow_player_input(false)
	
	_hud.timer_over.connect(func():
		allow_player_input(true)
		)
	
	_hud.start_timer(3)


func allow_player_input(allow:bool) -> void:
	for bubble in players_parent_node.get_children():
		if bubble is Bubble:
			bubble.allow_player_input(allow)


func _clear_players() -> void:
	for n in players_parent_node.get_children():
		players_parent_node.remove_child(n)
		n.queue_free() 

func _init_players(players:Array[Player]) -> void:
	for p in players:
		var spawn_pos:Vector3 = player_spawns.get_and_lock_spawn()
		
		var bubble:Bubble = bubble_scene.instantiate()
		players_parent_node.add_child(bubble)
		bubble.global_position = spawn_pos
		print("set color %s" % p.color)
		bubble.set_color_tint(p.color)
		bubble.player_device_id = p.id
