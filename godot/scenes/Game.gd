extends Node3D

@onready var main_menu_camera: Camera3D = $RotateCameraAnchor/MainMenuCamera
@export var menu:Control = null
@export var main_level:Node3D = null
@onready var target_camera_position: Marker3D = $BathtubLevel/TargetCameraPosition
@onready var rotate_camera_anchor: Node3D = $RotateCameraAnchor

@export var menu_scene:PackedScene = null

func _ready() -> void:
	randomize()
	
	init_main_menu()
	AudioManager.play_music(SoundBank.main_menu_music)
	AudioManager.play_music2(SoundBank.background_perc_music)
	AudioManager.mute_music2(true)
	
	Events.return_to_main_menu.connect(_on_return_to_main_menu)

func init_main_menu() -> void:
	if menu == null and menu_scene:
		menu = menu_scene.instantiate()
		add_child(menu)
	menu.request_game_start.connect(_on_request_game_start)
	rotate_camera_anchor.set_rotating(true)

func _on_return_to_main_menu() -> void:
	init_main_menu()
	main_level.end_level()

func _on_request_game_start(players:Array[Player]) -> void:
	main_level.start_level(players)
	menu.queue_free()
	rotate_camera_anchor.set_rotating(false)
	var tween: Tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rotate_camera_anchor, "rotation", Vector3.ZERO, 1.0)
	tween.tween_property(main_menu_camera, "transform", target_camera_position.transform, 1.0)
	
