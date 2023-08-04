class_name Slot
extends Control

signal match_done
signal move_done
signal swap_done
signal fill_done
signal change_done
signal replace_done

signal pressed
signal swiped(pos, dir)

var piece: Piece
var pos: Vector2i

func invalid_swap(dir: Vector2i):
	if piece:
		piece.slight_move(dir)

func swap(other_slot: Slot):
	if piece == null:
		return

	var other = other_slot.piece
	var piece_pos = get_pos()
	if other:
		other.move(piece_pos)
	piece.move(other_slot.get_pos())

	var temp = piece
	other_slot.piece = piece
	piece = other

	# Do not use connect. We want to wait for it only once
	await temp.move_done
	swap_done.emit()

func move(slot: Slot):
	if piece == null:
		return
	
	if slot.piece != null:
		# Please don't happen
		print("Other slot still has a piece. Cannot move there.")
		return
	
	piece.move(slot.get_pos())

	var temp = piece
	slot.piece = piece
	piece = null

	await temp.move_done
	move_done.emit()

func move_match(slot: Slot):
	if piece == null:
		return
	
	piece.move(slot.get_pos() + Vector2.UP)
	await piece.move_done
	matched()

func change_special(type: Specials.Type, special_piece):
	if piece == null:
		return
	
	piece.matched()
	piece.move(get_pos() + Vector2.UP)
	piece = special_piece
	piece.change_to(type)
	capture()
	await piece.change_done
	change_done.emit()

func capture():
	if piece:
		piece.global_position = get_pos()

func fill_drop():
	if piece == null:
		return
	
	piece.global_position = get_pos() + Vector2.UP * (abs(pos.y) + 1) * custom_minimum_size
	piece.move(get_pos())

	await piece.move_done
	fill_done.emit()

func get_pos():
	return global_position + custom_minimum_size / 2

func matched():
	if piece:
		var temp = piece
		piece.matched()
		piece = null

		await temp.match_done
		match_done.emit()

func replace(p):
	if piece:
		piece.matched()
		await piece.match_done
	piece = p
	capture()
	piece.show()
	piece.spawn()
	await piece.spawn_done

	replace_done.emit()

func _on_swipe_control_pressed():
	if piece:
		pressed.emit()


func _on_swipe_control_swiped(dir):
	if piece:
		swiped.emit(pos, dir)
