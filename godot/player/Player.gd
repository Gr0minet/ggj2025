class_name Player
extends Resource

@export var id: int = -1
@export var color: Color = Color.WHITE

func _init(p_id: int) -> void:
	id = p_id
