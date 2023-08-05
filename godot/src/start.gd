extends Control

@export var energy: Label
@export var points: Label

func _ready():
	energy.text = str(GameManager.energy)
	points.text = str(GameManager.points)

func _on_play_pressed():
	GameManager.start_game()
