class_name PlayerJoin
extends PanelContainer

signal request_game_start_by(player: Player)


@export var player_id: int


const JOIN_DELAY = 1.5

enum State{
	WAITING,
	JOINED,
	LAUNCHING,
	LAUNCHED
}

var current_state: State = State.WAITING

var player:Player = null

@onready var rich_text_label = $VBoxContainer/RichTextLabel
@onready var progress_bar = $TextureProgressBar

func _ready() -> void:
	waiting()


func progress_bar_reset() -> void:
	progress_bar.set_value_no_signal(0.0)


func waiting() -> void:
	current_state = State.WAITING
	rich_text_label.text = "[center]Joueur " + str(player_id + 1) + "
[img]res://assets/xbox_button_color_a_outline.png[/img]
pour rejoindre[/center]"
	progress_bar_reset()


func joined() -> void:
	current_state = State.JOINED
	
	player = Player.new(player_id)
	player.color = Color.WHITE
	
	rich_text_label.text = "[center]Joueur " + str(player_id + 1) + "
Maintiens
[img]res://assets/xbox_button_color_a_outline.png[/img]
pour lancer[/center]"
	progress_bar_reset()


func launching() -> void:
	current_state = State.LAUNCHING


func launched() -> void:
	current_state = State.LAUNCHED
	rich_text_label.text = "[center]Joueur " + str(player_id + 1) + "
Prépare-toi !"
	progress_bar.set_value_no_signal(100.0)


func _process(delta: float) -> void:
	if current_state == State.LAUNCHING:
		var new_value = progress_bar.value + delta / JOIN_DELAY * 100
		if new_value >= 100:
			launched()
			request_game_start_by.emit(player)
		else:
			progress_bar.set_value_no_signal(new_value)


func _unhandled_input(event: InputEvent) -> void:
	if event.device != player_id:
		return
	if event.is_action_pressed("join_game"):
		if current_state == State.WAITING:
			joined()
		else:
			launching()
	if event.is_action_released("join_game"):
		if current_state != State.LAUNCHED:
			joined()
