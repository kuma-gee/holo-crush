extends CenterContainer

signal close

@export var grid: GridContainer

func _ready():
	_update()
	visibility_changed.connect(_update)

func _update():
	for child in grid.get_children():
		grid.remove_child(child)
	
	for p in Piece.Type.values():
		if p in GameManager.default_pieces:
			continue
		
		var enabled = p in GameManager.unlocked_pieces
		var node = UIButton.new()
		node.texture_normal = GameManager.get_piece_profile(p)
		node.ignore_texture_size = true
		node.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		node.custom_minimum_size = Vector2(128, 128)
		node.pressed.connect(func(): GameManager.selected_piece = p)
#		l.text = Piece.Type.keys()[p]
		node.disabled = not enabled
		node.modulate = Color.WHITE if enabled else Color(0.3, 0.3, 0.3, 1.0)
		grid.add_child(node)

func _on_texture_button_pressed():
	close.emit()
