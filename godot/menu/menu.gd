extends Control

signal request_game_start(player_ids: Array[int])

@export var player_join_parent: Control = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in player_join_parent.get_children():
		child.request_game_start_by.connect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_request_game_start_by(_player_id: int) -> void:
	var player_ids = Array()
	for child in player_join_parent.get_children():
		if child.player_joined:
			player_ids.append(child.player_id)
	request_game_start.emit(player_ids)
