extends Node

var points := 0

var max_energy := 5
@onready var energy := max_energy

func scored(score: int):
	points += floor(score / 100)

func start_game():
#	if GameManager.energy > 0:
#		energy -= 1
	SceneManager.change_scene("res://src/game.tscn")
#	else:
#		print("No energy")
