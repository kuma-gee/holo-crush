extends Control

@onready var bgm := $BGM

func _on_play_pressed():
	GameManager.start_game()
	create_tween().tween_property(bgm, "volume_db", -50, 1.0).set_trans(Tween.TRANS_CUBIC)


func _on_check_energy_timer_timeout():
	GameManager.energy.restore()
