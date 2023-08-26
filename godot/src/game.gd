extends Control

@export var input_blocker: Control
@export var grid: GridUI
@export var move_timer: Timer

@export var turns_label: Label
@export var turns := 30

@export var gameover: Control
@export var end_score: Label
@export var score_ui: ScoreUI
@export var shockwave: Control
@export var turn_end: Control

var hint_shown = false

func _ready():
	turn_end.hide()
	gameover.hide()
	input_blocker.hide()
	turns_label.text = str(turns)
	move_timer.timeout.connect(func():
		if not hint_shown and turns > 0:
			grid.highlight_possible_move()
			hint_shown = true
	)
	
	var mat = shockwave.material as ShaderMaterial
	mat.set_shader_parameter("radius", 0.0)


func _on_grid_processing():
	input_blocker.show()


func _on_grid_processing_finished():
	if turns > 0:
		input_blocker.hide()
		move_timer.start()
	else:
		turn_end.show()
		if not grid.activate_specials():
			_on_gameover()

func _on_gameover():
	var score = score_ui.score
	end_score.text = tr("Score") + ": " + str(score)
	
	gameover.position = Vector2(0, -gameover.size.y)
	gameover.show()
	
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(gameover, "position", Vector2.ZERO, 0.5)
	
	GameManager.points.scored(score)


func _on_restart_pressed():
	GameManager.start_game()


func _on_grid_turn_used():
	turns -= 1
	turns_label.text = str(turns)
	move_timer.start()
	hint_shown = false


func _on_menu_pressed():
	SceneManager.change_scene("res://src/start.tscn")


func _set_shockwave_radius(value: float):
	var mat = shockwave.material as ShaderMaterial
	mat.set_shader_parameter("radius", value)


func _on_grid_explosion(pos):
	var center = (Vector2(pos) - shockwave.global_position) / shockwave.size
	var mat = shockwave.material as ShaderMaterial
	mat.set_shader_parameter("center", center)
	
	var tw = create_tween()
	tw.tween_method(_set_shockwave_radius, 0.3, 1.5, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
