extends PanelContainer


@export var player_id: int
@onready var rich_text_label = $VBoxContainer/RichTextLabel

func _ready() -> void:
	player_reset(self.player_id)




func player_reset(player_id: int) -> void:
	rich_text_label.text = "[center]Joueur " + str(player_id + 1) + "
[img]res://assets/xbox_button_color_a_outline.png[/img]
pour rejoindre[/center]"


func player_join(player_id: int) -> void:
	rich_text_label.text = "[center]Joueur " + str(player_id + 1) + "
Maintiens
[img]res://assets/xbox_button_color_a_outline.png[/img]
pour lancer[/center]"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_A:
			player_join(self.player_id)
		if event.pressed and event.keycode == KEY_Z:
			player_reset(self.player_id)
	if event.is_action_pressed("join_game"):
		player_join(self.player_id)
