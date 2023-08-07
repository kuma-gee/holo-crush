class_name Piece
extends Node2D

signal match_done
signal move_done
signal change_done
signal spawn_done
signal despawn_done

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

var special: Specials.Type

func move(dest: Vector2, fade_in = false):
	var tw = create_tween()
	tw.tween_property(self, "global_position", dest, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if fade_in:
		modulate = Color.TRANSPARENT
		tw.parallel().tween_property(self, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		
	tw.finished.connect(func(): move_done.emit())

func spawn():
	scale = Vector2.ZERO

	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func(): spawn_done.emit())

func despawn(finish_signal = despawn_done):
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func(): 
		finish_signal.emit()
		queue_free()
	)

func pressed():
	modulate = Color.GRAY

func released():
	modulate = Color.WHITE

func matched():
	despawn(match_done)

func slight_move(dir: Vector2):
	var tw = create_tween()
	var pos = global_position
	tw.tween_property(self, "global_position", pos + dir * slight_move_distance, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "global_position", pos, 0.25)
	await tw.finished

func change_to(s: Specials.Type):
	special = s
	_to_special(special)
	change_done.emit()

func _to_special(_special: Specials.Type):
	pass
