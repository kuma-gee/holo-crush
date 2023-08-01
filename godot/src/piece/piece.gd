class_name Piece
extends Node2D

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
@export var slight_move_distance := 10

@onready var swipe_control: SwipeControl = $SwipeControl

func _ready():
	swipe_control.pressed.connect(func(): pressed.emit())
	swipe_control.swiped.connect(func(dir): swiped.emit(dir))

func move(dest: Vector2):
	create_tween().tween_property(self, "global_position", dest, 0.5)#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)

func slight_move(dir: Vector2):
	var tw = create_tween()
	var pos = global_position
	tw.tween_property(self, "global_position", pos + dir * slight_move_distance, 0.25)
	tw.tween_property(self, "global_position", pos, 0.25)
