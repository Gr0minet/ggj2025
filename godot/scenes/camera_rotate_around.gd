extends Node3D


## Rotation speed in deci-degrees per seconds
@export var rotation_speed : float = 10
## Target the camera is looking at
@export var look_at_target:Node3D = null
@export var camera:Camera3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if look_at_target:
		global_position = look_at_target.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not look_at_target:
		return
		
	if not camera:
		return
	
	rotation.y += rotation_speed * delta / 10 # rotation speed is in decidegree
