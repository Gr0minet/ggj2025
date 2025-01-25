extends CanvasItem

@export var debug_mode:bool = true
@export var debug_target:Bubble = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _process(_delta:float) -> void:
	if not debug_mode:
		return
	if not debug_target:
		return;
	
	queue_redraw()

func _draw() -> void:
	# draw motion vector
	var position:Vector3 = debug_target.position
	var velocity:Vector3 = debug_target.velocity
	draw_line(position, position+velocity, Color.GREEN, 2.0)
