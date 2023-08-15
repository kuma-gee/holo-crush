extends Control

@export var label: Label
@export var added_label: Label

func _ready():
	_update_label()
	GameManager.points.points_added.connect(_on_points_added)
	added_label.modulate = Color.TRANSPARENT

func _update_label(points = GameManager.points.points):
	label.text = str(points)
	
func _update_added_label(points):
	added_label.text = "+ %s" % points

func _get_label_center():
	return label.global_position + label.size/2

func _on_points_added(curr, added):
	_update_added_label(added)
	added_label.pivot_offset = added_label.size / 2
	added_label.global_position = _get_label_center() + Vector2.DOWN * 30 - added_label.size / 2
	added_label.scale = Vector2(0, 0)
	
	var tw = create_tween()
	tw.tween_property(added_label, "modulate", Color.WHITE, 0.5).set_delay(1.0)
	tw.parallel().tween_property(added_label, "scale", Vector2(1, 1), 0.5).set_delay(1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tw.chain().tween_property(added_label, "modulate", Color.TRANSPARENT, 1.0).set_delay(0.5)
	tw.parallel().tween_method(_update_label, curr, curr + added, 1.0)
	tw.parallel().tween_method(_update_added_label, added, 0, 1.0)
