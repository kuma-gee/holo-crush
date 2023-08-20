extends Control

@export var selectables: Control
@export var select_container: Control
@export var menu_container: Control

@export var settings_menu: Control
@export var store_menu: Control

@onready var bgm := $BGM
@onready var start_sound := $StartSound

@onready var piece_select := $PieceSelect
@onready var anim := $AnimationPlayer

func _ready():
	anim.play("RESET")
	GameManager.game_started.connect(_on_game_start)

func _on_game_start():
	create_tween().tween_property(bgm, "volume_db", -50, 1.0).set_trans(Tween.TRANS_CUBIC)
	start_sound.play()

func _on_play_pressed():
	select_container.pivot_offset = select_container.size / 2
	anim.play("show_pieces")

func _on_check_energy_timer_timeout():
	GameManager.energy.restore()

func _on_start_pressed():
	GameManager.start_game()

func _on_piece_select_on_hide():
	anim.play_backwards("show_pieces")
	await anim.animation_finished
	piece_select.hide()


func _on_settings_pressed():
	store_menu.hide()
	settings_menu.show()
	_toggle_menu()
	

func _on_store_pressed():
	settings_menu.hide()
	store_menu.show()
	_toggle_menu()

func _is_menu_visible():
	return menu_container.position.y >= 0

func _toggle_menu():
	if anim.is_playing():
		return
	
	if _is_menu_visible():
		anim.play_backwards("show_menu")
	else:
		anim.play("show_menu")
