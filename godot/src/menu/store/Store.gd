extends CenterContainer

signal close()
signal unlocked(piece)

@export var pack_container: Control
@export var showcase: Control
@export var showcase_tex: TextureRect

var showing_showcase = false
var tw: Tween

func _ready():
	for child in pack_container.get_children():
		child.pressed.connect(func(): _unpack_gacha(child))

func _unpack_gacha(pack: GachaPack):
	if GameManager.points.use_points(pack.price):
		var new_piece = pack.get_pieces().pick_random()
		GameManager.unlock_piece(new_piece)
		print("unlocked %s" % Piece.Type.keys()[new_piece])
		unlocked.emit(new_piece)
	else:
		print("No money")

func _on_texture_button_pressed():
	close.emit()
