extends Node

signal energy_updated(energy)

const SAVE_SLOT = 0

@onready var save_manager := $SaveManager
@onready var energy := $Energy

var points := 0

func _ready():
	_load_game()

func _exit_tree():
	_save_game()

func scored(score: int):
	points += floor(score / 100)

func start_game():
	if energy.use_energy():
		SceneManager.change_scene("res://src/game.tscn")
	else:
		print("No energy")

func get_energy():
	return energy.energy

func _save_game():
	save_manager.save_to_slot(SAVE_SLOT, {
		"energy": get_energy()
	})

func _load_game():
	var data = save_manager.load_from_slot(SAVE_SLOT)
	if data == null:
		return
	
	if "energy" in data:
		energy.energy = data.energy
