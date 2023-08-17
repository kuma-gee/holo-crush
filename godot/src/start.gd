extends Control

@onready var bgm := $BGM
@onready var start_sound := $StartSound
@onready var piece_select := $PieceSelect

func _ready():
	piece_select.hide()
	GameManager.game_started.connect(_on_game_start)

func _on_game_start():
	create_tween().tween_property(bgm, "volume_db", -50, 1.0).set_trans(Tween.TRANS_CUBIC)
	start_sound.play()

func _on_play_pressed():
	piece_select.show()

func _on_check_energy_timer_timeout():
	GameManager.energy.restore()

func _on_start_pressed():
	GameManager.start_game()
