class_name Bubble
extends CharacterBody3D


@export_range(0,4) var player_device_id:int = 0
@export var acceleration : float = 0.05
@export var max_speed : float = 30.0
const JUMP_VELOCITY = 400.5
@export var gravity_scale:float = 1.0

const DEAD_ZONE = 0.5

var _input_dir:Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_scale
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		print("jump")
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	print(_input_dir, direction)
	if direction:
		velocity.x = move_toward(velocity.x, max_speed, acceleration * direction.x)
		velocity.z = move_toward(velocity.z, max_speed, acceleration * direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration)
		velocity.z = move_toward(velocity.z, 0, acceleration)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	
	if player_device_id != event.device:
		return
	
	if event is InputEventJoypadMotion:
		var motion_event: InputEventJoypadMotion = event as InputEventJoypadMotion
		var axis_value : float = motion_event.axis_value
		match motion_event.axis:
			JOY_AXIS_LEFT_X, JOY_AXIS_RIGHT_X:
				_input_dir.x = axis_value if abs(axis_value) >= DEAD_ZONE else 0.0
			JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_Y:
				_input_dir.y = axis_value if abs(axis_value) >= DEAD_ZONE else 0.0
