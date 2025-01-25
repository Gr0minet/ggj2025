extends PanelContainer


@export var player_id: int
@onready var rich_text_label = $VBoxContainer/RichTextLabel
@onready var progress_bar = $TextureProgressBar

var player_joined: bool
var join_touch_pressed = false
const JOIN_DELAY = 1.5

func _ready() -> void:
	player_reset()


func player_reset() -> void:
	rich_text_label.text = "[center]Joueur " + str(player_id + 1) + "
[img]res://assets/xbox_button_color_a_outline.png[/img]
pour rejoindre[/center]"
	player_joined = false
	progress_bar.value = 0.0


func player_join(join_player_id: int) -> void:
	if join_player_id == player_id:
		rich_text_label.text = "[center]Joueur " + str(player_id + 1) + "
Maintiens
[img]res://assets/xbox_button_color_a_outline.png[/img]
pour lancer[/center]"
	player_joined = true


func _process(delta: float) -> void:
	if join_touch_pressed:
		progress_bar.set_value_no_signal(progress_bar.value + delta / JOIN_DELAY * 100)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("join_game") and event.device == 0:
		if not player_joined:
			player_join(self.player_id)
		else:
			join_touch_pressed = true
	if event.is_action_released("join_game"):
		join_touch_pressed = false
