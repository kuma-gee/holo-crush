class_name Slot
extends Control

signal match_done
signal move_done
signal swap_done
signal swap_wrong_done
signal fill_done
signal change_done
signal replace_done

signal swiped(dir)

var height = 0
var piece: Piece
var pos: Vector2i

var slight_moving = false

@onready var click_sound := $ClickSound
@onready var swipe_sound := $SwipeSound
@onready var wrong_sound := $WrongSound
@onready var swipe_control := $SwipeControl
@onready var highlight_rect := $Highlight

const piece_size = Vector2(128, 128)

func _ready():
	highlight_rect.modulate = Color.TRANSPARENT

func highlight():
	var tw = create_tween()
	tw.tween_property(highlight_rect, "modulate", Color.WHITE, 0.5)
	get_tree().create_timer(3.0).timeout.connect(_unhighlight)

func _unhighlight():
	var tw = create_tween()
	tw.tween_property(highlight_rect, "modulate", Color.TRANSPARENT, 0.5)

func jump():
	piece.jump()

func invalid_swap(dir: Vector2i):
	if piece:
		slight_moving = true
		await piece.slight_move(dir)
		slight_moving = false

func swap_wrong(other_slot: Slot):
	swap(other_slot)
	await swap_done
	swap(other_slot)
	wrong_sound.play()
	await swap_done
	swap_wrong_done.emit()

func swap(other_slot: Slot):
	if piece == null:
		return

	var other = other_slot.piece
	var piece_pos = get_pos()
	if other:
		other.move(piece_pos, false, 0.3)
	piece.move(other_slot.get_pos(), false, 0.3)

	var temp = piece
	other_slot.piece = piece
	piece = other

	# Do not use connect. We want to wait for it only once
	await temp.move_done
	swap_done.emit()

func move(slot: Slot):
	if piece == null:
		return
	
	# if slot.piece != null:
	# 	# Please don't happen
	# 	print("Other slot still has a piece. Cannot move there.")
	# 	return

	var temp = piece
	piece = null
	slot.piece = temp
	
	temp.move(slot.get_pos())

	await temp.move_done
	move_done.emit()

func move_match(slot: Slot):
	if piece == null:
		return
	
	matched()

func change_special(type: Specials.Type, special_piece):
	if piece == null:
		return
	
	piece.matched()
	piece = special_piece
	piece.change_to(type)
	capture()
	await piece.change_done
	change_done.emit()

func capture():
	if piece:
		piece.global_position = get_pos()
		var actual_size = min(size.x, size.y)
		piece.scale = Vector2(actual_size, actual_size) / piece_size
		

func fill_drop():
	if piece == null:
		return
	
	capture()
	piece.global_position = get_pos() + Vector2.UP * (height - (abs(pos.y) + 1)) * size.y
	piece.move(get_pos(), true)

	await piece.move_done
	fill_done.emit()

func get_pos():
	return global_position + size / 2

func matched():
	if piece:
		var temp = piece
		piece.matched()
		piece = null
		match_done.emit()

func replace(p):
	if piece:
		piece.despawn()
		await piece.despawn_done
	piece = p
	capture()
	piece.show()
	piece.spawn()
	await piece.spawn_done
	capture()

	replace_done.emit()

func _can_move():
	return piece != null and not slight_moving

func _on_swipe_control_swiped(dir):
	if _can_move():
		swiped.emit(dir)
		swipe_sound.play()
		piece.released()


func _on_swipe_control_press_released():
	if _can_move():
		piece.released()


func _on_swipe_control_press_click():
	if _can_move():
		piece.pressed()
		click_sound.play()
