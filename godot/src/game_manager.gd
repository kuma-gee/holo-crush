extends Node

const SAVE_SLOT = 0

@onready var save_manager := $SaveManager
@onready var energy := $Energy
@onready var points := $Points

func _ready():
	_load_game()
	energy.restore()
	
	SceneManager.scene_loaded.connect(func():
		points.add_scored_points()
		_save_game()
	)

func _exit_tree():
	_save_game()

func start_game():
	if energy.use_energy():
		SceneManager.change_scene("res://src/game.tscn")

func back_to_start():
	SceneManager.change_scene("res://src/start.tscn")

func _save_game():
	save_manager.save_to_slot(SAVE_SLOT, {
		"energy": energy.energy,
		"energyUsedTime": energy.get_last_used_time(),
		"points": points.get_points()
	})

func _load_game():
	var data = save_manager.load_from_slot(SAVE_SLOT)
	if data == null:
		return
	
	if "energy" in data:
		energy.energy = data.energy
	if "energyUsedTime" in data:
		energy.set_last_used_time(data.energyUsedTime)
	if "points" in data:
		points.set_points(data.points)
