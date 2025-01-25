class_name PlayerSpawns
extends Node3D

var _spawn_available:Array[Vector3] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_spawns()

func reset_spawns() -> void:
	_spawn_available = []
	for c in get_children():
		_spawn_available.append(c.global_position)

# Returns -1,-1,-1 if no available
func get_and_lock_spawn() -> Vector3:
	if len(_spawn_available) == 0:
		return Vector3(-1, -1, -1)
	
	var spawn_pos:Variant= _spawn_available.pop_at(randi_range(0, len(_spawn_available) - 1))
	
	if spawn_pos == null:
		return Vector3(-1, -1, -1)
	
	return spawn_pos
	
