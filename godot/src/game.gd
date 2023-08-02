extends Control

@export var input_blocker: Control

func _ready():
	input_blocker.hide()


func _on_grid_processing():
	input_blocker.show()


func _on_grid_processing_finished():
	input_blocker.hide()

