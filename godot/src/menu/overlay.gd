extends Control

signal on_hide()

@export var external := false

func _gui_input(event):
	if event.is_action_pressed("click"):
		if external:
			on_hide.emit()
		else:
			hide()
