extends TextureButton

signal select_for(idx, pos)

@export var index := 0

var piece

func _ready():
	update()
	pressed.connect(func():
		select_for.emit(index, global_position + size/2)
		piece.queue_free()
		piece = null
	)

func update():
	if piece:
		piece.queue_free()
	piece = _create_piece(GameManager.selected_pieces[index], self)

func _create_piece(p, parent):
	var node = GameManager.PIECE_MAP[p].instantiate()
	node.position = size / 2
	parent.add_child(node)
	node.show()
	return node
