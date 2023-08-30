class_name UIButton
extends TextureButton

var tw: Tween

func _ready():
	button_down.connect(func():
		_tween()
		tw.tween_property(self, "scale", Vector2(0.8, 0.8), 0.25)
		tw.tween_property(self, "modulate", Color.GRAY, 0.25)
	)
	button_up.connect(func():
		_tween()
		tw.tween_property(self, "scale", Vector2(1, 1), 0.25)
		tw.tween_property(self, "modulate", Color.WHITE, 0.25)
	)

func _tween():
	if tw:
		tw.kill()
	
	tw = create_tween()
	tw.set_parallel()
	tw.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	pivot_offset = size / 2
