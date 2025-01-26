class_name Bubble
extends CharacterBody3D


@export_range(0,4) var player_device_id:int = 0
@export var acceleration : float = 1.6
@export var deceleration : float = 0.4
@export var max_speed : float = 10.0
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@onready var bullesaturee: Node3D = $BULLESATUREE

# Material and color related variables
@export var mesh_instance : MeshInstance3D = null
var _mesh_material:StandardMaterial3D = null

const DEAD_ZONE = 0.5

var allow_input:bool = true

var _input_dir:Vector2 = Vector2.ZERO

var _bounce_sounds:Array[AudioStream] = [
	SoundBank.bounce1,
	SoundBank.bounce2,
]

func _ready() -> void:
	if mesh_instance:
		_mesh_material = mesh_instance.get_active_material(0).duplicate()
		mesh_instance.set_surface_override_material(0, _mesh_material)

func _physics_process(delta: float) -> void:

	if not allow_input:
		return

	# Get the input direction and handle the movement/deceleration.
	var direction := (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	if direction:
		#velocity.x += acceleration * direction.x * delta
		#velocity.z += acceleration * direction.z * delta
		velocity.x = move_toward(velocity.x, max_speed, acceleration * direction.x * delta)
		velocity.z = move_toward(velocity.z, max_speed, acceleration * direction.z * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration*delta)
		velocity.z = move_toward(velocity.z, 0, deceleration*delta)

	var collision : KinematicCollision3D = move_and_collide(velocity * delta)
	_handle_collision(collision, false)


func _unhandled_input(event: InputEvent) -> void:
	if player_device_id != event.device:
		return
	
	# Inputs are recorded even if allow_input == false
	# so that when the game start, the input_dir is already set
	
	if event is InputEventJoypadMotion:
		var motion_event: InputEventJoypadMotion = event as InputEventJoypadMotion
		var axis_value : float = motion_event.axis_value
		match motion_event.axis:
			JOY_AXIS_LEFT_X:
				_input_dir.x = axis_value if abs(axis_value) >= DEAD_ZONE else 0.0
			JOY_AXIS_LEFT_Y:
				_input_dir.y = axis_value if abs(axis_value) >= DEAD_ZONE else 0.0


func die() -> void:
	cpu_particles_3d.emitting = true
	bullesaturee.visible = false
	await cpu_particles_3d.finished
	queue_free.call_deferred()

func allow_player_input(allow:bool) -> void:
	allow_input = allow

func _handle_collision(collision : KinematicCollision3D, debug:bool=false) -> void:
	if not collision:
		return
	
	AudioManager.play_sound_effect(_bounce_sounds.pick_random())
	
	if velocity.length() < 0.05:
		return
	
	var collider := collision.get_collider()
	var velocity_to_collider:float = 0.8
	var velocity_to_self:float = 0.3 # bounce back
	var repulsion_vector:Vector3 = collision.get_normal()
	
	#print("%s collides with %s (%s)" % [name, collider.name, collider])
	#print(collision is Item)
	
	# walls are not moved
	if collider is StaticBody3D:
		velocity_to_collider = 0.0
		velocity_to_self = 0.9 # not 1 because y a de la perte
	elif collider is Item:
		die()
		return
	
	if not is_zero_approx(velocity_to_collider):
		collider.velocity = velocity.bounce(repulsion_vector) * velocity_to_collider * -1
		if collider.velocity.length() > max_speed:
			collider.velocity = collider.velocity.normalized() * max_speed
		collider.velocity.y = 0
	
	velocity = velocity.bounce(collision.get_normal()) * velocity_to_self
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	velocity.y = 0

## If preserve_alpha, keep the old alpha and only change the rgb
func set_color_tint(color:Color, preserve_alpha:bool=true):
	var old_alpha : float = _mesh_material.albedo_color.a
	if preserve_alpha:
		color.a = old_alpha
	_mesh_material.albedo_color = color
