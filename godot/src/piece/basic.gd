extends Piece

@onready var sprite := $Sprite2D
@onready var back_color := $BackColor
@onready var shard_emitter := $Sprite2D/ShardEmitter

@export var normal_texture: Texture2D
@export var row_texture: Texture2D
@export var col_texture: Texture2D
@export var bomb_texture: Texture2D

func _ready():
	var mat = (back_color.material as ShaderMaterial).duplicate()
	mat.set_shader_parameter("color_gradient", _create_gradient())
	back_color.material = mat
	back_color.hide()

func _create_gradient():
	var gradient = Gradient.new()
	gradient.set_color(0, sprite.modulate)
	gradient.set_color(1, sprite.modulate)
	var gradient_tex = GradientTexture1D.new()
	gradient_tex.gradient = gradient
	return gradient_tex

func matched():
	SoundManager.play_match_break()
	shard_emitter.shatter()
	
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tw.finished.connect(func():
		match_done.emit()
		queue_free()
	)

func _to_special(special: Specials.Type):
	var texture = normal_texture
	back_color.hide()
	
	match special:
		Specials.Type.ROW: texture = row_texture
		Specials.Type.COL: texture = col_texture
		Specials.Type.BOMB: texture = bomb_texture
		Specials.Type.COLOR_BOMB: back_color.show()
	
	sprite.texture = texture
