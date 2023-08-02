class_name Slot
extends Control

signal match_done
signal move_done
signal swap_done
signal fill_done

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
		piece.move(other_slot.get_pos())
		piece.move_done.connect(func(): swap_done.emit())

		other_slot.piece = piece
		piece = other

func move(slot: Slot):
	if piece == null:
		return
	
	if slot.piece != null:
		# Please don't happen
		print("Other slot still has a piece. Cannot move there.")
		return
	
	piece.move(slot.get_pos())
	piece.move_done.connect(func(): move_done.emit())
	slot.piece = piece
	piece = null

func capture():
	if piece:
		piece.global_position = get_pos()

func fill_drop():
	if piece == null:
		return
	
	piece.global_position = get_pos() + Vector2.UP * (abs(pos.y) + 1) * custom_minimum_size
	piece.move(get_pos())
	piece.move_done.connect(func(): fill_done.emit())

func get_pos():
	return global_position + custom_minimum_size / 2

func matched():
	if piece:
		piece.matched()
		piece.match_done.connect(func(): match_done.emit())
		piece = null

func replace(p):
	if piece:
		piece.queue_free()
	piece = p
	capture()

func _on_swipe_control_pressed():
	if piece:
		pressed.emit()


func _on_swipe_control_swiped(dir):
	if piece:
		swiped.emit(pos, dir)
