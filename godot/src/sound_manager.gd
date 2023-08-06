extends Node

@onready var match_sound := $MatchSound

func play_match():
	match_sound.play_debounce(0.1)
