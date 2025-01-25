extends CanvasItem

@export var debug_mode:bool = true
@export var debug_targets:Array[Bubble] = []
@export var camera:Camera3D = null

@export_flags("Draw Velocity", "Draw Input") var draw_flags = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _process(_delta:float) -> void:
	if not debug_mode:
		return
	if len(debug_targets) == 0:
		return;
	
	queue_redraw()

func _draw() -> void:
	print(draw_flags)
	for debug_target in debug_targets:		
		if draw_flags & 1:
			# draw motion vector
			var position:Vector2 = camera.unproject_position(debug_target.position)
			var velocity:Vector2 = camera.unproject_position(debug_target.position + debug_target.velocity)
			draw_line(position, velocity, Color.GREEN, 2.0)
		
		if draw_flags & 2:
			# draw input
			var position:Vector2 = camera.unproject_position(debug_target.position)
			var dir:Vector2 = position + debug_target._input_dir*40
			draw_line(position, dir, Color.YELLOW, 2.0)
