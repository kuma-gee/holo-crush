class_name SwipeControl
extends Control

signal press_click
signal press_released
signal swiped(dir)

@export var swipe_threshold := 100

var swipe_start
var current_dir

func _gui_input(event: InputEvent):
	if event.is_action_pressed("click") and event is InputEventMouseButton:
		press_click.emit()
		swipe_start = global_position + event.position
	if event.is_action_released("click") and swipe_start != null and event is InputEventMouseButton:
		press_released.emit()
		swipe_start = null

func _calculate_swipe(swipe_end = get_viewport().get_mouse_position()):
	if swipe_start != null:
		var swipe: Vector2 = swipe_end - swipe_start
		
		if swipe.length() > swipe_threshold:
			var dir = Vector2i(swipe.normalized().round())
			if dir.length() > 1:
				dir.y = 0
			return dir
	return Vector2.ZERO

func _process(delta):
	current_dir = _calculate_swipe()
	if current_dir.length() >= 1:
		swiped.emit(current_dir)
		swipe_start = null
