extends Piece

@onready var sprite := $Sprite2D

@export var normal_texture: Texture2D
@export var row_texture: Texture2D
@export var col_texture: Texture2D

func _to_special(special: MatchGrid.Special):
	var texture = normal_texture
	match special:
		MatchGrid.Special.ROW: texture = row_texture
		MatchGrid.Special.COL: texture = col_texture
	
	sprite.texture = texture
