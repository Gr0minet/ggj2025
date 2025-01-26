extends PanelContainer


var match_length = "3":
	get:
		return match_length
	set(value):
		match_length = value
		$MarginContainer/MatchLengthHBox/MatchLengthLabel.text = match_length
