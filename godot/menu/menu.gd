extends Control

signal request_game_start(players: Array[Player])

@export var player_join_parent: Control = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in player_join_parent.get_children():
		child.request_game_start_by.connect(_on_request_game_start_by)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_request_game_start_by(player: Player) -> void:
	var players: Array[Player] = [player]
	for child in player_join_parent.get_children():
		if child.current_state != child.State.WAITING and child.player_id != player.id:
			players.append(Player.new(child.player_id))
			child.launched()
	request_game_start.emit(players)
