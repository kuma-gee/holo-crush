extends PanelContainer

signal selected(idx, piece)

@export var selectable_container: Control
@export var selectable_scene: PackedScene

const SLOT_SIZE = 128
var current_index

func _ready():
	hide()

func show_selectable_pieces(idx, pos):
	if visible:
		close()
	
	current_index = idx
	for child in selectable_container.get_children():
		selectable_container.remove_child(child)

	var pieces = _selectable_pieces()
	for p in pieces:
		selectable_container.add_child(_create_selectable_piece(p))

	var selected = _create_selectable_piece(GameManager.selected_pieces[idx])
	selectable_container.add_child(selected)
	
	selectable_container.move_child(selected, _selected_index())
	show()
	global_position = pos - size / 2
	if selectable_container.get_child_count() % 2 == 0:
		global_position.y += (SLOT_SIZE / 2)
		

func _selected_index():
	return ceil(selectable_container.get_child_count() / 2.0) - 1

func _scroll_dir(dir):
	var box = selectable_container
	if dir.y > 0:
		box.move_child(box.get_child(box.get_child_count() - 1), 0)
	else:
		box.move_child(box.get_child(0), box.get_child_count() - 1)

func _selectable_pieces():
	var result = []
	for p in GameManager.get_selectable_pieces():
		if p in GameManager.selected_pieces:
			continue
		result.append(p)
	return result

func _create_selectable_piece(p):
	var slot = selectable_scene.instantiate()
	slot.piece = p

	var node = _create_piece(p, slot)
	slot.scroll_to.connect(_scroll_dir)
	slot.pressed.connect(func(): _pressed_selectable(slot))
	return slot

func _pressed_selectable(node):
	var idx = _find_idx_for_selectable(node)
	if idx < 0:
		return
		
	var center = _selected_index()
	var diff = center - idx
	
	if diff == 0:
		close()
	else:
		while diff != 0:
			_scroll_dir(Vector2(0, sign(diff)))
			diff -= diff / abs(diff)

func close():
	if visible:
		var s = selectable_container.get_child(_selected_index())
		GameManager.set_selected_piece(current_index, s.piece)
		selected.emit(current_index, s.piece)
		hide()

func _find_idx_for_selectable(node):
	for i in selectable_container.get_child_count():
		if selectable_container.get_child(i) == node:
			return i
	return -1

func _create_piece(p, parent):
	var node = GameManager.PIECE_MAP[p].instantiate()
	node.position = Vector2(SLOT_SIZE, SLOT_SIZE) / 2
	parent.add_child(node)
	node.show()
	return node
