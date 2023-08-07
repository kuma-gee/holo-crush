extends Node

@onready var match_sound := $MatchSound
@onready var special_match := $SpecialMatch

func play_match():
	match_sound.play_debounce(0.1)

func play_special_match():
	special_match.play_debounce(0.1)
