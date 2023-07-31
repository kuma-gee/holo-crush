class_name Piece
extends Control

signal pressed
signal swiped(dir)

enum Type {
	INA,
	KIARA,
	AME,
	GURA,
	CALLI
}

@export var type: Type
@export var swipe_threshold := 100

var swipe_start

func _gui_input(event: InputEvent):
	if event.is_action_pressed("click") and event is InputEventMouseButton:
		pressed.emit()
		swipe_start = event.global_position
	if event.is_action_released("click") and event is InputEventMouseButton:
		_calculate_swipe(event.global_position)
		swipe_start = null

func _calculate_swipe(swipe_end):
	if swipe_start == null:
		return
	var swipe: Vector2 = swipe_end - swipe_start
	
	if swipe.length() > swipe_threshold:
		var dir = swipe.normalized().round()
		if dir.length() > 1:
			dir.y = 0
		print("Swipe for ", Type.keys()[type])
		swiped.emit(dir)

func move(dest: Vector2):
	create_tween().tween_property(self, "global_position", dest, 0.5)#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)

func type_name():
	return Type.keys()[type]
