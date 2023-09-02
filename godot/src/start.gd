extends Control

@export var collection_btn: Control
@export var collection_hint: GPUParticles2D

@export var energy_time_label: Label

@onready var bgm := $BGM
@onready var start_sound := $StartSound

const EMPTY = preload("res://assets/ui/empty.svg")

var play_hint = false

func _ready():
	GameManager.game_started.connect(_on_game_start)
	GameManager.selected_piece_changed.connect(_update_collection_btn)
	GameManager.first_unlocked.connect(func(): play_hint = true)
	_update_collection_btn(GameManager.selected_piece)
	
	energy_time_label.visible = GameManager.energy.energy == 0

func _update_collection_btn(piece):
	var tex = GameManager.get_piece_profile(piece)
	var mat = collection_btn.material as ShaderMaterial
	mat.set_shader_parameter("clip_texture", tex if tex else EMPTY)

func _on_game_start():
	create_tween().tween_property(bgm, "volume_db", -50, 1.0).set_trans(Tween.TRANS_CUBIC)
	start_sound.play()

func _on_play_pressed():
	GameManager.start_game()

func _on_check_energy_timer_timeout():
	GameManager.energy.restore()
	energy_time_label.text = GameManager.energy.get_remaining_time()

func _on_start_pressed():
	GameManager.start_game()

func _on_store_hidden():
	if play_hint:
		collection_hint.emitting = true
		play_hint = false
