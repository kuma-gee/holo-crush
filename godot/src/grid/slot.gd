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
@onready var icing := $Icing
@onready var ring := $Ring
@onready var panel := $Panel

const piece_size = Vector2(128, 128)
const BASE_MOVE_TIME = 0.5

var showing_special = false
var icing_count = 0 : set = _set_icing_count

func _ready():
	icing.material = icing.get_material().duplicate()
	icing.hide()
	
	highlight_rect.modulate = Color.TRANSPARENT
	ring.modulate = Color.TRANSPARENT

func _set_icing_count(c):
	icing_count = c
	update_icing()

func update_icing():
	if icing_count <= 0:
		icing.hide()
		return
	
	icing.show()
	var mat = icing.material as ShaderMaterial
	mat.set_shader_parameter("radius", 1.3 - (icing_count - 1) * 0.2)

func blocked():
	panel.hide()

func highlight():
	_show_brief(highlight_rect)

func _show_brief(node, time = 0.5, hold_time = 3.0):
	var tw = create_tween()
	tw.tween_property(node, "modulate", Color.WHITE, time / 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	get_tree().create_timer(hold_time).timeout.connect(func():
		var t = create_tween()
		t.tween_property(node, "modulate", Color.TRANSPARENT, time / 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	)
	await tw.finished

func jump():
	if piece:
		piece.jump()

func invalid_swap(dir: Vector2i):
	if piece:
		slight_moving = true
		await piece.slight_move(dir)
		slight_moving = false

func swap_wrong(other_slot: Slot):
	if piece and other_slot.piece:
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
	if piece:
		var temp = piece
		piece = null
		slot.piece = temp
		
		# var dist = abs(slot.pos.y) - abs(pos.y)
		temp.move(slot.get_pos(), false, BASE_MOVE_TIME)

		await temp.move_done
	move_done.emit()

func capture():
	if piece:
		piece.global_position = get_pos()
		var actual_size = min(size.x, size.y)
		piece.scale = Vector2(actual_size, actual_size) / piece_size
		piece.show()
		

func fill_drop():
	if piece:
		capture()
		var above = abs(pos.y) - height - 1
		piece.global_position = get_pos() + above * Vector2(0, size.y)

		# var dist = abs(pos.y) - above
		piece.move(get_pos(), true, BASE_MOVE_TIME)

		await piece.move_done

	fill_done.emit()

func get_pos():
	return global_position + size / 2

func matched(special_type):
	if piece:
		if special_type == null:
			piece.matched()
			piece = null
		else:
			piece.change_to(special_type)

	match_done.emit()

func icing_matched():
	self.icing_count -= 1

func pulse_ring():
	var tw = create_tween()
	ring.modulate = Color.WHITE
	tw.tween_property(ring, "modulate", Color.TRANSPARENT, 0.5)
	tw.parallel().tween_method(_set_ring_radius, 0.0, 1.0, 0.5)

func _set_ring_radius(value: float):
	var mat = ring.material as ShaderMaterial
	mat.set_shader_parameter("radius", value)

func replace(p):
	if piece:
		piece.despawn()
		await piece.despawn_done
	piece = p
	capture()
	piece.spawn()
	await piece.spawn_done
	capture()

	replace_done.emit()

func _can_move():
	return piece != null and not slight_moving

func _on_swipe_control_swiped(dir):
	if _can_move():
		piece.released()
		swiped.emit(dir)
		swipe_sound.play()


func _on_swipe_control_press_released():
	if _can_move():
		piece.released()


func _on_swipe_control_press_click():
	if _can_move():
		piece.pressed()
		click_sound.play()
