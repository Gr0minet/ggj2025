class_name SecheCheveux
extends Node3D


@export var DURATION: float = 5.0

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _timer: Timer = $Timer
@onready var _area_3d: Area3D = $Pivot/Area3D
@onready var _cpu_particles_3d: CPUParticles3D = $Pivot/CPUParticles3D

var _body_inside_wind: Array[Node3D] = []

func _ready() -> void:
	_animation_player.play("fade_in")
	await _animation_player.animation_finished
	_start_venting()

func set_wind_position_to_water_level(water_level: float) -> void:
	_area_3d.global_position.y = water_level + 0.1 # small delta to add here, idk why
	_area_3d.global_rotation.x = 0.0


func _physics_process(delta: float) -> void:
	var wind_factor: float = 1.0
	for body: Node3D in _body_inside_wind:
		if body is Bubble:
			wind_factor = 2.0
		body.velocity += Vector3.BACK.rotated(Vector3.UP, rotation.y) * wind_factor * delta


func _start_venting() -> void:
	_timer.start(DURATION)
	_cpu_particles_3d.emitting = true


func _remove() -> void:
	_cpu_particles_3d.emitting = false
	_animation_player.play("fade_out")
	await _animation_player.animation_finished
	queue_free()


func _on_timer_timeout() -> void:
	_remove()


func _on_area_3d_body_entered(body: Node3D) -> void:
	_body_inside_wind.append(body)
	#print(body, " entering wind")


func _on_area_3d_body_exited(body: Node3D) -> void:
	_body_inside_wind.remove_at(_body_inside_wind.find(body))
	#print(body, " exiting wind")
