extends Node3D


@onready var _hud: HUD = $HUD


func _ready() -> void:
	_hud.start_timer(3)
