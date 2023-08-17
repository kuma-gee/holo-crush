extends Node

const SAVE_SLOT = 0

signal game_started()

@onready var save_manager := $SaveManager
@onready var energy := $Energy
@onready var points := $Points

const PIECE_MAP := {
	Piece.Type.BLUE: preload("res://src/piece/basic_blue.tscn"),
	Piece.Type.RED: preload("res://src/piece/basic_red.tscn"),
	Piece.Type.YELLOW: preload("res://src/piece/basic_yellow.tscn"),
	Piece.Type.GREEN: preload("res://src/piece/basic_green.tscn"),
	Piece.Type.PURPLE: preload("res://src/piece/basic_purple.tscn"),
	
	Piece.Type.INA: preload("res://src/piece/ina.tscn"),
	Piece.Type.AME: preload("res://src/piece/ame.tscn"),
	Piece.Type.GURA: preload("res://src/piece/gura.tscn"),
	Piece.Type.KIARA: preload("res://src/piece/kiara.tscn"),
	Piece.Type.CALLI: preload("res://src/piece/calli.tscn"),
}

var unlocked_pieces = Piece.Type.values()

var selected_pieces: Array[Piece.Type] = [
	Piece.Type.BLUE,
	Piece.Type.RED,
	Piece.Type.YELLOW,
	Piece.Type.GREEN,
	Piece.Type.PURPLE,
]

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
		game_started.emit()

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
