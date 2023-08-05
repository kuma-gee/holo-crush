extends Control

@export var game: PackedScene

func _on_play_pressed():
	get_tree().change_scene_to_packed(game)
