class_name Piece
extends Node2D

enum Type {
	INA,
	KIARA,
	AME,
	GURA,
	CALLI
}

@export var type: Type
@export var slight_move_distance := 10

@onready var label: Label = $Sprite2D/Label

func _ready():
	label.text = str(type) + ", " + Type.keys()[type]

func move(dest: Vector2):
	create_tween().tween_property(self, "global_position", dest, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

func slight_move(dir: Vector2):
	var tw = create_tween()
	var pos = global_position
	tw.tween_property(self, "global_position", pos + dir * slight_move_distance, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "global_position", pos, 0.25)
