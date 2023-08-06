class_name ScoreUI
extends Control

@export var score_add: PackedScene
@export var score_label: Label

@onready var add_timer := $ShowAddTimer

var score = 0
var total_added = 0

func _ready():
	score_label.text = str(score)

func add_score(value: int, combo: int):
	score += value
	total_added += value
	add_timer.start(0.1)


func _on_show_add_timer_timeout():
	var add = score_add.instantiate()
	score_label.add_child(add)
	add.set_value(total_added)
	
	total_added = 0
	
	var tw = create_tween()
	tw.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.25)
	tw.tween_property(score_label, "scale", Vector2(1, 1), 0.25)
	score_label.pivot_offset = score_label.size / 2
	score_label.text = str(score)
