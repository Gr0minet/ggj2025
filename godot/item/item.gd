class_name Item
extends CharacterBody3D


@export var acceleration : float = 0.8
@export var deceleration : float = 0.2
@export var max_speed : float = 10.0


func _physics_process(delta: float) -> void:
	if velocity:
		velocity -= velocity * deceleration * delta
	var collision: KinematicCollision3D = move_and_collide(velocity * delta)
	_handle_collision(collision)


func _handle_collision(collision : KinematicCollision3D, debug:bool=false) -> void:
	if not collision:
		return
	
	#print(collision)
	
	if velocity.length() < 0.05:
		return
	
	var collider := collision.get_collider()
	var velocity_to_collider:float = 0.8
	var velocity_to_self:float = 0.3 # bounce back
	var repulsion_vector:Vector3 = collision.get_normal()
	
	
	# walls are not moved
	if collider is StaticBody3D:
		velocity_to_collider = 0.0
		velocity_to_self = 0.9 # not 1 because y a de la perte
	
	if not is_zero_approx(velocity_to_collider):
		collider.velocity = velocity.bounce(repulsion_vector) * velocity_to_collider * -1
		if collider.velocity.length() > max_speed:
			collider.velocity = collider.velocity.normalized() * max_speed
		collider.velocity.y = 0
	
	velocity = velocity.bounce(collision.get_normal()) * velocity_to_self
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	velocity.y = 0
