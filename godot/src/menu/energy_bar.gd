extends TextureRect

@export var enable_color: Color
@export var disable_color: Color

var value = true : set = _set_value

func _set_value(v):
	value = v
	modulate = enable_color if v else disable_color
