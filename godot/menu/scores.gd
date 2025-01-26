extends PanelContainer


signal request_next_round()


var game_length: int
var scores: Dictionary
var current_round = 0
var players: Array[Player]
@onready var scores_label_hbox = $VBoxContainer/ScoresLabelVBox
@onready var rounds_label = $VBoxContainer/RoundsLabel


func sort_player(a: Player, b: Player) -> bool:
	return a.id < b.id

# Called when the node enters the scene tree for the first time.
func init() -> void:
	scores = {}
	players.sort_custom(sort_player)
	for player in players:
		scores[player.id] = 0
	if game_length > 0:
		rounds_label.text = "First to " + str(game_length) + " wins it all!"
	else:
		rounds_label.text = "No score limit, bubble on!"


func update_scores_label():
	for child in scores_label_hbox.get_children():
		scores_label_hbox.remove_child(child)
	for player in players:
		var label = Label.new()
		label.add_theme_color_override("font_color", player.color)
		label.add_theme_color_override("font_outline", Color.BLACK)
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_font_size_override("font_size", 48)
		var score = scores[player.id]
		label.text = "J%d's score: %d point%s" % [player.id + 1, score, "" if score <= 1 else "s"]
		scores_label_hbox.add_child(label)


func bubble_wins(bubble_id: int):
	if bubble_id == -1:
		return
	scores[bubble_id] += 1
	print(scores)
	update_scores_label()



func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("join_game"):
		request_next_round.emit()
