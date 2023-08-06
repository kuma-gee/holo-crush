extends Control

@onready var label := $Label

var move = true

func _ready():
	var tw = create_tween()
	var dir = Vector2.UP * 30
	var actual = dir.rotated(randf_range(0, -PI/2))
	if move:
		tw.tween_property(self, "global_position", global_position + actual, 0.5)
	
	tw.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	
	tw.finished.connect(func(): queue_free())

func set_value(v):
	label.text = str(v)
