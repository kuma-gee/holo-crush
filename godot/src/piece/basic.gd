extends Piece

@onready var back_color := $BackColor
@onready var anim := $AnimationPlayer
@onready var match_particles := $MatchParticles

@export var normal_texture: Texture2D
@export var row_texture: Texture2D
@export var col_texture: Texture2D
@export var bomb_texture: Texture2D

func _ready():
	var mat = (back_color.material as ShaderMaterial).duplicate()
	mat.set_shader_parameter("color_gradient", _create_gradient())
	back_color.material = mat
	back_color.hide()
	match_particles.emitting = false
	
	var mat2 = (sprite.material as ShaderMaterial).duplicate()
	sprite.material = mat2

func _create_gradient():
	var gradient = Gradient.new()
	gradient.set_color(0, sprite.modulate)
	gradient.set_color(1, sprite.modulate)
	var gradient_tex = GradientTexture1D.new()
	gradient_tex.gradient = gradient
	return gradient_tex

func matched():
	SoundManager.play_match()
	
	var tw = create_tween()
	tw.tween_method(_set_shader_value, 0.5, -1.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.finished.connect(func():
		match_done.emit()
		queue_free()
	)

func _set_shader_value(value: float):
	var mat = sprite.material as ShaderMaterial
	mat.set_shader_parameter("progress", value)

func _to_special(special: Specials.Type):
	SoundManager.play_special_match()
	var texture = normal_texture
	back_color.hide()
	anim.play("special_match")
	
	match special:
		Specials.Type.ROW: texture = row_texture
		Specials.Type.COL: texture = col_texture
		Specials.Type.BOMB: texture = bomb_texture
		Specials.Type.COLOR_BOMB: back_color.show()
	
	sprite.texture = texture
