class_name MenuSystem
extends Control

@export var overlay: ColorRect

var tw: Tween
var overlay_speed := 0.25
var move_speed := 0.5
var outside_pos := Vector2(0, -2000)

func _ready():
	overlay.hide()

func _show_overlay():
	overlay.modulate = Color.TRANSPARENT
	overlay.show()
	tw.tween_property(overlay, "modulate", Color.WHITE, overlay_speed) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)

func _hide_overlay():
	tw.chain().tween_property(overlay, "modulate", Color.TRANSPARENT, overlay_speed) \
		.from(Color.WHITE) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)
	tw.finished.connect(func(): overlay.hide())

func _new_tween():
	if tw:
		tw.kill()
	tw = create_tween()

func _show_node(node):
	_new_tween()
	_show_overlay()
	
	node.position = Vector2(0, -node.size.y)
	node.show()
	tw.parallel().tween_property(node, "position", Vector2.ZERO, move_speed) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)

func _hide_node(node):
	_new_tween()
	
	tw.tween_property(node, "position", outside_pos, move_speed) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_BACK)
	tw.finished.connect(func(): node.hide())
	
	_hide_overlay()
