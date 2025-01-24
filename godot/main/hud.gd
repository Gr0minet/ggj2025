class_name HUD
extends Control


@onready var _countdown_label: Label = $CountdownLabel
@onready var _countdown: Timer = $Countdown


func start_timer(start_countdown: int) -> void:
	_countdown_label.visible = true
	_countdown.start(start_countdown)


func _process(delta: float) -> void:
	if not _countdown.is_stopped():
		_countdown_label.text = "%d" % [int(_countdown.time_left) + 1]


func _on_countdown_timeout() -> void:
	_countdown.stop()
	_countdown_label.text = "GO"
	await get_tree().create_timer(1.0).timeout
	_countdown_label.visible = false
