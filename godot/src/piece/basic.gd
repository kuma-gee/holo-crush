extends Piece

@onready var sprite := $Sprite2D

@export var normal_texture: Texture2D
@export var row_texture: Texture2D
@export var col_texture: Texture2D
@export var bomb_texture: Texture2D

func _to_special(special: Specials.Type):
	var texture = normal_texture
	match special:
		Specials.Type.ROW: texture = row_texture
		Specials.Type.COL: texture = col_texture
		Specials.Type.BOMB: texture = bomb_texture
	
	sprite.texture = texture
