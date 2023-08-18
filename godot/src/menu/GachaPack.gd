class_name GachaPack
extends TextureButton

@export var price := 0
@export var pieces: Array[Piece.Type] = []

func get_pieces():
	if pieces.size() > 0:
		return pieces
		
	var unlockables = []
	for p in Piece.Type.values():
		if p in GameManager.default_pieces:
			continue
		unlockables.append(p)
	return unlockables
