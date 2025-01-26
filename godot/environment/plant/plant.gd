extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var animation_player_3: AnimationPlayer = $AnimationPlayer3


func _ready() -> void:
	animation_player.play("leafAction_002")
	animation_player.get_animation("leafAction_002").loop_mode = Animation.LOOP_LINEAR
	animation_player_2.play("leaf_001Action")
	animation_player_2.get_animation("leaf_001Action").loop_mode = Animation.LOOP_LINEAR
	animation_player_3.play("leaf_002Action")
	animation_player_3.get_animation("leaf_002Action").loop_mode = Animation.LOOP_LINEAR
