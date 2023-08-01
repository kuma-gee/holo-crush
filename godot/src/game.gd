extends Control

@export var input_blocker: Control

func _ready():
	input_blocker.hide()


func _on_grid_moving():
	input_blocker.show()


func _on_grid_moving_finished():
	input_blocker.hide()
