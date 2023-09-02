extends Node

@onready var match_sound := $MatchSound
@onready var special_match := $SpecialMatch
@onready var bomb_sound := $BombSound
@onready var click_sound := $ClickSound
@onready var close_sound := $CloseSound

func play_match():
	match_sound.play_debounce(0.1)

func play_special_match():
	special_match.play_debounce(0.1)

func play_bomb():
	bomb_sound.play_debounce(0.1)

func play_click():
	click_sound.play_debounce(0.1)

func play_close():
	close_sound.play_debounce(0.1)
