extends Control

@export var input_blocker: Control

@export var turns_label: Label
@export var turns := 10

@export var score_label: Label
var score = 0

func _ready():
	input_blocker.hide()
	turns_label.text = str(turns)
	score_label.text = str(score)


func _on_grid_processing():
	input_blocker.show()


func _on_grid_processing_finished():
	if turns > 0:
		input_blocker.hide()


func _on_grid_swapped():
	turns -= 1
	turns_label.text = str(turns)
	if turns <= 0:
		pass


func _on_grid_scored(value):
	score += value
	score_label.text = str(score)
