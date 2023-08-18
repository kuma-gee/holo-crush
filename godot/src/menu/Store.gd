extends Control

@export var pack_container: Control

@onready var store_container := $PanelContainer

func _ready():
	store_container.hide()
	
	for child in pack_container.get_children():
		child.pressed.connect(func(): _unpack_gacha(child))

func _on_store_pressed():
	if store_container.visible:
		store_container.hide()
	else:
		store_container.show()

func _unpack_gacha(pack: GachaPack):
	if GameManager.points.use_points(pack.price):
		var new_piece = pack.get_pieces().pick_random()
		GameManager.unlock_piece(new_piece)
		print("unlocked %s" % Piece.Type.keys()[new_piece])
	else:
		print("No money")
