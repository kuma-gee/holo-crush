extends TextureButton

signal scroll_to(dir)

var piece
var idx

func _on_swipe_control_swiped(dir):
	if dir.x > 0:
		return
		
	scroll_to.emit(dir)


func _on_swipe_control_press_released():
	pressed.emit()
