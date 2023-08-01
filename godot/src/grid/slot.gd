class_name Slot
extends Control

signal pressed
signal swiped(pos, dir)

var piece: Piece
var pos: Vector2i

func failed_move(dir: Vector2i):
	piece.slight_move(dir)

func move(other_slot: Slot):
	var other = other_slot.piece
	var piece_pos = global_position
	piece.move(other_slot.global_position)
	other.move(piece_pos)

	other_slot.piece = piece
	piece = other

func capture():
	if piece:
		piece.global_position = global_position

func matched():
	piece.modulate = Color(1, 1, 1, 0.5)


func _on_swipe_control_pressed():
	pressed.emit()


func _on_swipe_control_swiped(dir):
	swiped.emit(pos, dir)
