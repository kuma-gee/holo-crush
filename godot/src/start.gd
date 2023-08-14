extends Control

@export var energy: EnergyContainer
@export var points: Label

@onready var anim := $AnimationPlayer

func _ready():
	points.text = str(GameManager.points)

func _on_play_pressed():
	GameManager.start_game()
