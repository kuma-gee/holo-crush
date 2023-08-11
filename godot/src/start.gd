extends Control

@export var energy: Label
@export var points: Label

@onready var anim := $AnimationPlayer

func _ready():
	energy.text = str(GameManager.energy)
	points.text = str(GameManager.points)

func _on_play_pressed():
	GameManager.start_game()
