extends Node

signal energy_updated(energy)

var points := 0

var max_energy := 5
@onready var energy := max_energy : set = _set_energy

func _set_energy(v):
	energy = v
	energy_updated.emit(energy)

func scored(score: int):
	points += floor(score / 100)

func start_game():
	if energy > 0:
		self.energy -= 1
		SceneManager.change_scene("res://src/game.tscn")
	else:
		print("No energy")
