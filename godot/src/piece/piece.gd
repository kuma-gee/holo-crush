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

@onready var swipe_control: SwipeControl = $SwipeControl

func _ready():
	swipe_control.pressed.connect(func(): pressed.emit())
	swipe_control.swiped.connect(func(dir): swiped.emit(dir))

func move(dest: Vector2):
	create_tween().tween_property(self, "global_position", dest, 0.5)#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
