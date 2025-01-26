extends Node3D

@onready var main_menu_camera: Camera3D = $RotateCameraAnchor/MainMenuCamera
@export var menu:Control = null
@export var main_level:Node3D = null
@onready var target_camera_position: Marker3D = $BathtubLevel/TargetCameraPosition
@onready var rotate_camera_anchor: Node3D = $RotateCameraAnchor

@export var menu_scene:PackedScene = null

@export var scores_scene: PackedScene = null
var scores_node: Control
var players: Array[Player]
var initial_menu_camera_transform: Transform3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()
	randomize()
	
	init_main_menu()
	AudioManager.play_music(SoundBank.main_menu_music)
	AudioManager.play_music2(SoundBank.background_perc_music)
	AudioManager.mute_music2(true)
	
	Events.return_to_main_menu.connect(_on_return_to_main_menu)
	initial_menu_camera_transform = main_menu_camera.transform

func init_main_menu() -> void:
	if menu == null and menu_scene:
		menu = menu_scene.instantiate()
		add_child(menu)
	menu.request_game_start.connect(_on_request_game_start)
	rotate_camera_anchor.set_rotating(true)

func _on_return_to_main_menu() -> void:
	init_main_menu()
	main_level.end_level()
	var tween: Tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(main_menu_camera, "transform", initial_menu_camera_transform, 1.0)

func reset() -> void:
	players = []
	scores_node = null

func start_round() -> void:
	main_level.start_level(players)
	rotate_camera_anchor.set_rotating(false)
	var tween: Tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rotate_camera_anchor, "rotation", Vector3.ZERO, 1.0)
	tween.tween_property(main_menu_camera, "transform", target_camera_position.transform, 1.0)


func _on_request_game_start(players_arr:Array[Player], match_length: int) -> void:
	players = players_arr
	menu.queue_free()
	start_round()
	scores_node = scores_scene.instantiate()
	add_child(scores_node)
	scores_node.players = players.duplicate(true)
	scores_node.game_length = match_length
	scores_node.init()
	scores_node.hide()
	scores_node.request_next_round.connect(_on_request_next_round)


func _on_request_next_round() -> void:
	scores_node.hide()
	start_round()


func _on_bathtub_level_bubble_won(bubble_id: int) -> void:
	main_level.end_level()
	scores_node.bubble_wins(bubble_id)
	if scores_node.scores.values().max() == scores_node.game_length:
		scores_node.win_screen()
		scores_node.show()
	else:
		scores_node.show()
	# print("You won" + str(bubble_id))
	# start_round(players)
