extends Control

@export var collection_btn: Control

@onready var bgm := $BGM
@onready var start_sound := $StartSound

func _ready():
	GameManager.game_started.connect(_on_game_start)
	GameManager.selected_piece_changed.connect(_update_collection_btn)
	_update_collection_btn(GameManager.selected_piece)

func _update_collection_btn(piece):
	var tex = GameManager.get_piece_profile(piece)
	var mat = collection_btn.material as ShaderMaterial
	mat.set_shader_parameter("clip_texture", tex)

func _on_game_start():
	create_tween().tween_property(bgm, "volume_db", -50, 1.0).set_trans(Tween.TRANS_CUBIC)
	start_sound.play()

func _on_play_pressed():
	GameManager.start_game()

func _on_check_energy_timer_timeout():
	GameManager.energy.restore()

func _on_start_pressed():
	GameManager.start_game()
