extends Control

@export var label: Label
@export var added_label: Label
@export var icon: TextureRect
@export var coin_sounds: Node

var started_volume_decrease = false
var coin_volume = -10
var adding_coins := 1.0

func _ready():
	_update_label()
	GameManager.points.points_added.connect(_on_points_added)
	added_label.modulate = Color.TRANSPARENT

func _update_label(points = GameManager.points.points):
	label.text = str(points)
	
func _update_added_label(points):
	added_label.text = "+ %s" % points
	
	if points / adding_coins < 0.25 and not started_volume_decrease:
		for child in coin_sounds.get_children():
			var tw = create_tween()
			tw.tween_property(child, "volume_db", -30, 0.5)
		started_volume_decrease = true

func _get_label_center():
	return label.global_position + label.size/2

func _on_points_added(curr, added):
	adding_coins = added
	
	_update_added_label(added)
	added_label.pivot_offset = added_label.size / 2
	added_label.global_position = _get_label_center() + Vector2.DOWN * 30 - added_label.size / 2
	added_label.scale = Vector2(0, 0)
	
	var delay = 1.0
	started_volume_decrease = false
	
	get_tree().create_timer(delay + 0.5).timeout.connect(func():
		for i in coin_sounds.get_child_count():
			var child = coin_sounds.get_child(i) as AudioStreamPlayer
			child.volume_db = coin_volume
			get_tree().create_timer(0.1 * i).timeout.connect(func(): child.play())
	)
	
	var tw = create_tween()
	tw.tween_property(added_label, "modulate", Color.WHITE, 0.5).set_delay(delay)
	tw.parallel().tween_property(added_label, "scale", Vector2(1, 1), 0.5).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
#	var orig_pos = icon.position
#	tw.parallel().tween_property(icon, "position", orig_pos + Vector2.UP * 3, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
#	tw.parallel().tween_property(icon, "position", orig_pos, 0.5).set_trans(Tween.TRANS_CUBIC).set_delay(0.5)
	
	tw.chain().tween_property(added_label, "modulate", Color.TRANSPARENT, 1.0).set_delay(0.5)
	tw.parallel().tween_method(_update_label, curr, curr + added, 1.0)
	tw.parallel().tween_method(_update_added_label, added, 0, 1.0)
	
	await tw.finished
	for child in coin_sounds.get_children():
		child.stop()
