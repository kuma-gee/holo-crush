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
		
		var l = Label.new()
		l.text = Piece.Type.keys()[p]
		l.modulate = Color.WHITE if p in GameManager.unlocked_pieces else Color(0.3, 0.3, 0.3, 1.0)
		grid.add_child(l)

func _on_texture_button_pressed():
	close.emit()
