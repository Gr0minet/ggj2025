extends Node3D

@export var menu:Control = null
@export var main_level:Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	menu.request_game_start.connect(_on_request_game_start)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_request_game_start(players:Array[Player]) -> void:
	main_level.start_level(players)
	menu.hide()
