extends RichTextLabel


func _ready():
	if OS.get_name() != "HTML5":
		meta_clicked.connect(_on_meta_clicked)


func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
