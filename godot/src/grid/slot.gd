class_name Slot
extends Control

signal match_done
signal pressed
signal swiped(pos, dir)

var piece: Piece
var pos: Vector2i

func invalid_move(dir: Vector2i):
	piece.slight_move(dir)

func move(other_slot: Slot):
	var other = other_slot.piece
	var piece_pos = get_pos()
	piece.move(other_slot.get_pos())
	await other.move(piece_pos)

	other_slot.piece = piece
	piece = other

func capture():
	if piece:
		piece.global_position = get_pos()

func get_pos():
	return global_position + custom_minimum_size / 2

func matched():
	await piece.matched()
	match_done.emit()


func _on_swipe_control_pressed():
	pressed.emit()


func _on_swipe_control_swiped(dir):
	swiped.emit(pos, dir)
