extends Node3D

signal bubble_won(bubble_id: int)

@export var seche_cheveux_min_respawn_time: float = 0.0
@export var seche_cheveux_max_respawn_time: float = 1.0
@export var players_parent_node:Node3D = null
@export var player_spawns:PlayerSpawns = null
@export var bubble_scene:PackedScene = null
@export var seche_cheveux_scene: PackedScene = null
@export var items_parent_node:Node3D = null
@export var seche_cheveux_parent_node:Node3D = null

var game_started:bool = false


@onready var _flotte: Node3D = $FLOTTE2
@onready var _seche_cheveux_respawn_timer: Timer = $SecheCheveuxRespawnTimer
@onready var _hud: HUD = $HUD

var alive_bubbles: Array[int] = []
var min_alive: int = 0


func _ready() -> void:
	allow_player_input(false)
	_save_items_positions()

func start_level(players:Array[Player]) -> void:
	game_started = true
	AudioManager.mute_music2(false)
	
	_clear_seche_cheveux()
	_clear_players()
	_reset_items_positions()
	_init_players(players)
	
	allow_player_input(false)
	
	_hud.timer_over.connect(func():
		allow_player_input(true)
		_set_seche_cheveux_respawn_timer()
	)
	
	_hud.start_timer(3)
	
func end_level() -> void:
	_hud.interrupt_timer()
	game_started = false
	AudioManager.mute_music2(true)
	allow_player_input(false)
	_clear_players()

func allow_player_input(allow:bool) -> void:
	for bubble in players_parent_node.get_children():
		if bubble is Bubble:
			bubble.allow_player_input(allow)

func _save_items_positions() -> void:
	for n in items_parent_node.get_children():
		var item:Item = n as Item
		item.set_initial_position_to_current_position()

func _reset_items_positions() -> void:
	for n in items_parent_node.get_children():
		var item:Item = n as Item
		item.reset_position_to_initial_position()

func _clear_players() -> void:
	for n in players_parent_node.get_children():
		players_parent_node.remove_child(n)
		n.queue_free() 

func _clear_seche_cheveux() -> void:
	for n in seche_cheveux_parent_node.get_children():
		seche_cheveux_parent_node.remove_child(n)
		n.queue_free() 

func _init_players(players:Array[Player]) -> void:
	player_spawns.reset_spawns()
	min_alive = 1 if players.size() > 1 else 0
	alive_bubbles.clear()
	for p in players:
		alive_bubbles.append(p.id)
		var spawn_pos:Vector3 = player_spawns.get_and_lock_spawn()
		
		var bubble:Bubble = bubble_scene.instantiate()
		bubble.bubble_died.connect(_on_bubble_died)
		players_parent_node.add_child(bubble)
		bubble.global_position = spawn_pos
		#print("set color %s" % p.color)
		bubble.set_color_tint(p.color)
		bubble.player_device_id = p.id


func _on_bubble_died(bubble_id: int) -> void:
	var index = alive_bubbles.find(bubble_id)
	if index == -1:
		return
	alive_bubbles.remove_at(index)
	if alive_bubbles.size() <= min_alive:
		bubble_won.emit(alive_bubbles[0] if alive_bubbles.size() > 0 else -1)


func _spawn_seche_cheveux() -> void:
	var seche_cheveux_spawns: Array[Node] = $SecheCheveuxSpawns.get_children()
	var seche_cheveux_spawn: Marker3D = seche_cheveux_spawns[randi_range(0, len(seche_cheveux_spawns) - 1)]
	var seche_cheveux: SecheCheveux = seche_cheveux_scene.instantiate()
	seche_cheveux.transform = seche_cheveux_spawn.global_transform
	seche_cheveux_parent_node.add_child(seche_cheveux)
	seche_cheveux.set_wind_position_to_water_level(_flotte.global_position.y)
	seche_cheveux.tree_exited.connect(_on_seche_cheveux_exiting)


func _on_seche_cheveux_exiting() -> void:
	# only queue for respawn another seche cheveux when game has started
	if game_started:
		_set_seche_cheveux_respawn_timer()
	else:
		_seche_cheveux_respawn_timer.stop()


func _set_seche_cheveux_respawn_timer() -> void:
	var seche_cheveux_respawn_time: float = randf_range(
		seche_cheveux_min_respawn_time,
		seche_cheveux_min_respawn_time
	)
	_seche_cheveux_respawn_timer.start(seche_cheveux_respawn_time)


func _on_seche_cheveux_respawn_timer_timeout() -> void:
	_spawn_seche_cheveux()


func _unhandled_input(event: InputEvent) -> void:
	if not game_started:
		return
	if event.is_action_pressed("pause"):
		# mark as handled to not unpause immediately :)
		get_viewport().set_input_as_handled()
		Events.pause()
