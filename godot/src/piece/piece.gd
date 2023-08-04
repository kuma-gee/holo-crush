class_name Piece
extends Node2D

signal match_done
signal move_done
signal change_done

enum Type {
	BLUE,
	RED,
	YELLOW,
	GREEN,
	PURPLE,
	
	INA,
	KIARA,
	AME,
	GURA,
	CALLI
}

@export var type: Type
@export var slight_move_distance := 10

func move(dest: Vector2):
	var tw = create_tween()
	tw.tween_property(self, "global_position", dest, 0.5).set_trans(Tween.TRANS_BACK)#.set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func(): move_done.emit())

func matched():
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func(): 
		match_done.emit()
		queue_free()
	)

func slight_move(dir: Vector2):
	var tw = create_tween()
	var pos = global_position
	tw.tween_property(self, "global_position", pos + dir * slight_move_distance, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "global_position", pos, 0.25)

func change_to(special: Data.Special):
	var tw = create_tween()
	tw.tween_property(self, "rotation", TAU, 1.0).set_trans(Tween.TRANS_BACK)
	tw.finished.connect(func(): change_done.emit())
	_to_special(special)

func _to_special(_special: Data.Special):
	pass
