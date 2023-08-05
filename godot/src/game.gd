extends Control

@export var input_blocker: Control
@export var grid: GridUI

@export var turns_label: Label
@export var turns := 30

@export var gameover: Control
@export var end_score: Label
@export var score_label: Label
var score = 0

func _ready():
	gameover.hide()
	input_blocker.hide()
	turns_label.text = str(turns)
	score_label.text = str(score)


func _on_grid_processing():
	input_blocker.show()


func _on_grid_processing_finished():
	if turns > 0:
		input_blocker.hide()
	else:
		if not grid.activate_specials():
			_on_gameover()

func _on_gameover():
	end_score.text = tr("Score") + ": " + str(score)
	gameover.show()

func _on_grid_scored(value):
	score += value
	score_label.text = str(score)


func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_grid_turn_used():
	turns -= 1
	turns_label.text = str(turns)
