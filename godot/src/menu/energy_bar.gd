extends Control

@export var enable_tex: TextureRect
@export var disable_tex: TextureRect

@onready var enable_color := enable_tex.modulate

var value = true : set = _set_value
var initial = true

func _ready():
	enable_tex.material = enable_tex.material.duplicate()

func _set_value(v):
	if v == value:
		initial = false
		return
	
	value = v
	enable_tex.position = Vector2.ZERO
	
	if initial:
		enable_tex.modulate = enable_color if value else Color.TRANSPARENT
		initial = false
		return
		
	if not value:
		var tw = create_tween()
		tw.tween_property(enable_tex, "modulate", Color.TRANSPARENT, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(enable_tex, "position", Vector2.LEFT * 20, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		enable_tex.position = Vector2.LEFT * 20
		var tw = create_tween()
		tw.tween_property(enable_tex, "modulate", enable_color, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(enable_tex, "position", Vector2.ZERO, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
#	var mat = enable_tex.material as ShaderMaterial
#	var start = mat.get_shader_parameter("dissolve_amount")
#	var end = 1.0 if value else 0.0
#	var tw = create_tween()
#	tw.tween_method(_set_enabled_progress, start, end, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	

func _set_enabled_progress(value):
	var mat = enable_tex.material as ShaderMaterial
	mat.set_shader_parameter("dissolve_amount", value)
	
func _set_enabled_shine(value):
	var mat = enable_tex.material as ShaderMaterial
	mat.set_shader_parameter("shine_progress", value)
