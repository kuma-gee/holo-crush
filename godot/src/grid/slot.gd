class_name Slot
extends ColorRect

var piece: Piece

func move(other_slot: Slot):
	var other = other_slot.piece
	var piece_pos = piece.global_position
	piece.move(other.global_position)
	other.move(piece_pos)

	other_slot.piece = piece
	piece = other

func capture():
	if piece:
		piece.global_position = global_position
