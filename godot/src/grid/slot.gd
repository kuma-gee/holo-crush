class_name Slot
extends Control

signal match_done
signal pressed
signal swiped(pos, dir)

var piece: Piece
var pos: Vector2i

func invalid_swap(dir: Vector2i):
	if piece:
		piece.slight_move(dir)

func swap(other_slot: Slot):
	if piece:
		var other = other_slot.piece
		var piece_pos = get_pos()
		if other:
			other.move(piece_pos)
		await piece.move(other_slot.get_pos())

		other_slot.piece = piece
		piece = other

func capture():
	if piece:
		piece.global_position = get_pos()

func get_pos():
	return global_position + custom_minimum_size / 2

func matched():
	if piece:
		await piece.matched()
		piece = null
		match_done.emit()


func _on_swipe_control_pressed():
	if piece:
		pressed.emit()


func _on_swipe_control_swiped(dir):
	if piece:
		swiped.emit(pos, dir)
