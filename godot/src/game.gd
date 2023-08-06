extends Control

@export var input_blocker: Control
@export var grid: GridUI

@export var turns_label: Label
@export var turns := 30

@export var gameover: Control
@export var end_score: Label
@export var score_ui: ScoreUI


func _ready():
	gameover.hide()
	input_blocker.hide()
	turns_label.text = str(turns)


func _on_grid_processing():
	input_blocker.show()


func _on_grid_processing_finished():
	if turns > 0:
		input_blocker.hide()
	else:
		if not grid.activate_specials():
			_on_gameover()

func _on_gameover():
	var score = score_ui.score
	end_score.text = tr("Score") + ": " + str(score)
	gameover.show()
	GameManager.scored(score)


func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_grid_turn_used():
	turns -= 1
	turns_label.text = str(turns)


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://src/start.tscn")
