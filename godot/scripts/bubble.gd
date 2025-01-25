class_name Bubble
extends CharacterBody3D


@export_range(0,4) var player_device_id:int = 0
@export var acceleration : float = 0.8
@export var deceleration : float = 0.2
@export var max_speed : float = 10.0
#const JUMP_VELOCITY = 400.5
#@export var gravity_scale:float = 1.0

const DEAD_ZONE = 0.5

var _input_dir:Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta * gravity_scale
	
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#print("jump")
		#velocity.y = JUMP_VELOCITY

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
	
	if event is InputEventJoypadMotion:
		var motion_event: InputEventJoypadMotion = event as InputEventJoypadMotion
		var axis_value : float = motion_event.axis_value
		match motion_event.axis:
			JOY_AXIS_LEFT_X:
				_input_dir.x = axis_value if abs(axis_value) >= DEAD_ZONE else 0.0
			JOY_AXIS_LEFT_Y:
				_input_dir.y = axis_value if abs(axis_value) >= DEAD_ZONE else 0.0


func die() -> void:
	queue_free.call_deferred()


func _handle_collision(collision : KinematicCollision3D, debug:bool=false) -> void:
	if not collision:
		return
	
	if velocity.length() < 0.05:
		return
	
	var collider := collision.get_collider()
	var velocity_to_collider:float = 0.8
	var velocity_to_self:float = 0.3 # bounce back
	var repulsion_vector:Vector3 = collision.get_normal()
	
	print("%s collides with %s (%s)" % [name, collider.name, collider])
	#print(collision is Item)
	
	# walls are not moved
	if collider is StaticBody3D:
		velocity_to_collider = 0.0
		velocity_to_self = 0.9 # not 1 because y a de la perte
	elif collider.is_in_group("item"):
		die()
	
	if not is_zero_approx(velocity_to_collider):
		collider.velocity = velocity.bounce(repulsion_vector) * velocity_to_collider * -1
		if collider.velocity.length() > max_speed:
			collider.velocity = collider.velocity.normalized() * max_speed
		collider.velocity.y = 0
	
	velocity = velocity.bounce(collision.get_normal()) * velocity_to_self
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	velocity.y = 0
