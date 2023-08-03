extends Piece

@onready var sprite := $Sprite2D

@export var normal_texture: Texture2D
@export var row_texture: Texture2D
@export var col_texture: Texture2D

func _to_special(special: Data.Special):
	var texture = normal_texture
	match special:
		Data.Special.ROW: texture = row_texture
		Data.Special.COL: texture = col_texture
	
	sprite.texture = texture
