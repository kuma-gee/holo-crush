extends CenterContainer

signal close()


func _on_texture_button_pressed():
	close.emit()
