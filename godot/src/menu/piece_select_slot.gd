extends TextureButton

signal pressed()

@export var index := 0
@export var selectable_root: Control
@export var selectable_scene: PackedScene

var piece

func _ready():
	var p = GameManager.selected_pieces[index]
	piece = GameManager.PIECE_MAP[p].instantiate()
	add_child(piece)

func _gui_input(event: InputEvent):
	if event.is_action_pressed("click") and event is InputEventMouseButton:
		if selectable_root.visible:
			selectable_root.hide()
		else:
			_show_selectable_pieces()

func _show_selectable_pieces():
	for child in selectable_root.get_children():
		selectable_root.remove_child(child)

	var pieces = _selectable_pieces()
	for p in pieces:
		var node = GameManager.PIECE_MAP[p].instantiate()
		var slot = selectable_scene.instantiate()
		slot.add_child(node)
		slot.pressed.connect(func():
			GameManager.selected_pieces[index] = p
			piece.queue_free()
			piece = node
			selectable_root.hide()
		)
		selectable_root.add_child(slot)

	selectable_root.show()

func _selectable_pieces():
	var result = []
	for p in GameManager.unlocked_pieces:
		if p in GameManager.selected_pieces:
			continue
		result.append(p)
	return result
