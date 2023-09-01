extends Node

const SAVE_SLOT = 0

signal game_started()
signal selected_piece_changed(piece)
signal first_unlocked()

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

const PIECE_PROFILE := {
	Piece.Type.INA: preload("res://assets/gacha/profile/Profile_Ina.png"),
	Piece.Type.AME: preload("res://assets/gacha/profile/Profile_Ame.png"),
	Piece.Type.GURA: preload("res://assets/gacha/profile/Profile_Gura.png"),
	Piece.Type.KIARA: preload("res://assets/gacha/profile/Profile_Kiara.png"),
	Piece.Type.CALLI: preload("res://assets/gacha/profile/Profile_Calli.png"),
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
var selected_piece = null : set = _set_selected_piece

func _ready():
	_load_game()
	energy.restore()
	
	if selected_pieces.size() > 0:
		selected_pieces = []
	if selected_pieces.size() == 0:
		selected_pieces.append_array(default_pieces)
	
	SceneManager.scene_loaded.connect(func():
		points.add_scored_points()
		#_save_game()
	)

func _exit_tree():
	points.add_scored_points()
	_save_game()

func unlock_piece(p):
	if p in unlocked_pieces:
		return
	
	if unlocked_pieces.size() == 0:
		first_unlocked.emit()
	unlocked_pieces.append(p)
	#_save_game()

func _set_selected_piece(piece):
	selected_piece = piece
	selected_piece_changed.emit(piece)
	#_save_game()

func get_piece_profile(piece):
	if not piece in PIECE_PROFILE:
		return null
	return PIECE_PROFILE[piece]


func start_game():
	if energy.use_energy():
		SceneManager.change_scene("res://src/game.tscn")
		game_started.emit()

func back_to_start():
	SceneManager.change_scene("res://src/start.tscn")

func _save_game():
	save_manager.save_to_slot(SAVE_SLOT, {
		"energy": energy.energy,
		"energy_used_time": energy.get_last_used_time(),
		"points": points.get_points(),
		"unlocked_pieces": unlocked_pieces,
		"selected_piece": selected_piece,
		#"selectedPieces": selected_pieces,
	})

func _load_game():
	var data = save_manager.load_from_slot(SAVE_SLOT)
	if data == null:
		return
	
	if "energy" in data:
		energy.energy = data.energy
	if "energy_used_time" in data:
		energy.set_last_used_time(data.energy_used_time)
	if "points" in data:
		points.set_points(data.points)
	if "unlocked_pieces" in data:
		unlocked_pieces = data.unlocked_pieces
	if "selected_piece" in data:
		selected_piece = data.selected_piece
	#if "selectedPieces" in data:
	#	selected_pieces = data.selectedPieces
