extends PanelContainer


var match_length = 3:
	get:
		return match_length
	set(value):
		match_length = value
		var match_length_str: String
		if value < 0:
			match_length_str = "∞"
		else:
			match_length_str = str(value)
		$MarginContainer/MatchLengthHBox/MatchLengthLabel.text = match_length_str
