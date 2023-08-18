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

var default_pieces = [
	Piece.Type.BLUE,
	Piece.Type.RED,
	Piece.Type.YELLOW,
	Piece.Type.GREEN,
	Piece.Type.PURPLE
]

var unlocked_pieces = []
var selected_pieces = []

func _ready():
	_load_game()
	energy.restore()
	
	if selected_pieces.size() == 0:
		selected_pieces.append_array(default_pieces)
	
	SceneManager.scene_loaded.connect(func():
		points.add_scored_points()
		_save_game()
	)

func _exit_tree():
	_save_game()

func unlock_piece(p):
	if not p in unlocked_pieces:
		unlocked_pieces.append(p)
	_save_game()

func set_selected_piece(idx: int, piece):
	selected_pieces[idx] = piece
	_save_game()

func get_selectable_pieces():
	var result = unlocked_pieces.duplicate()
	result.append_array(default_pieces)
	return result


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
		"points": points.get_points(),
		"unlockedPieces": unlocked_pieces,
		"selectedPieces": selected_pieces,
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
	if "unlocked_pieces" in data:
		unlocked_pieces = data.unlocked_pieces
	if "selected_pieces" in data:
		selected_pieces = data.selected_pieces
