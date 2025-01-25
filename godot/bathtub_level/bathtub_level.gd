extends Node3D

@export var seche_cheveux_min_respawn_time: float = 0.0
@export var seche_cheveux_max_respawn_time: float = 1.0
@export var players_parent_node:Node3D = null
@export var player_spawns:PlayerSpawns = null
@export var bubble_scene:PackedScene = null
@export var seche_cheveux_scene: PackedScene = null
@onready var _flotte: Node3D = $FLOTTE2

@onready var _seche_cheveux_respawn_timer: Timer = $SecheCheveuxRespawnTimer
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
	_set_seche_cheveux_respawn_timer()


func _spawn_seche_cheveux() -> void:
	var seche_cheveux_spawns: Array[Node] = $SecheCheveuxSpawns.get_children()
	var seche_cheveux_spawn: Marker3D = seche_cheveux_spawns[randi_range(0, len(seche_cheveux_spawns) - 1)]
	var seche_cheveux: SecheCheveux = seche_cheveux_scene.instantiate()
	seche_cheveux.transform = seche_cheveux_spawn.global_transform
	add_child(seche_cheveux)
	seche_cheveux.set_wind_position_to_water_level(_flotte.global_position.y)
	seche_cheveux.tree_exited.connect(_on_seche_cheveux_exiting)


func _on_seche_cheveux_exiting() -> void:
	_set_seche_cheveux_respawn_timer()


func _set_seche_cheveux_respawn_timer() -> void:
	var seche_cheveux_respawn_time: float = randf_range(
		seche_cheveux_min_respawn_time,
		seche_cheveux_min_respawn_time
	)
	_seche_cheveux_respawn_timer.start(seche_cheveux_respawn_time)


func _on_seche_cheveux_respawn_timer_timeout() -> void:
	_spawn_seche_cheveux()
