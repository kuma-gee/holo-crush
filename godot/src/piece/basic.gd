extends Piece

@onready var back_color := $BackColor
@onready var anim := $AnimationPlayer
@onready var match_particles := $MatchParticles

@export var normal_texture: Texture2D
@export var row_texture: Texture2D
@export var col_texture: Texture2D
@export var bomb_texture: Texture2D

var special_type

func _ready():
	hide()
	var mat = (back_color.material as ShaderMaterial).duplicate()
	mat.set_shader_parameter("color_gradient", _create_gradient())
	back_color.material = mat
	back_color.hide()
	match_particles.emitting = false
	
	sprite.material = sprite.material.duplicate()

func _create_gradient():
	var gradient = Gradient.new()
	gradient.set_color(0, sprite.modulate)
	gradient.set_color(1, sprite.modulate)
	var gradient_tex = GradientTexture1D.new()
	gradient_tex.gradient = gradient
	return gradient_tex

func matched():
	_play_sound()
	
	anim.play("match")
	await anim.animation_finished
	match_done.emit()
	queue_free()

func _play_sound(default_sound = func(): SoundManager.play_match()):
	match special_type:
		Specials.Type.BOMB: SoundManager.play_bomb()
		Specials.Type.ROW: SoundManager.play_bomb()
		Specials.Type.COL: SoundManager.play_bomb()
		Specials.Type.COLOR_BOMB: SoundManager.play_bomb()
		_: default_sound.call()

func _to_special(special: Specials.Type):
	_play_sound(func(): SoundManager.play_special_match())
	var texture = normal_texture
	back_color.hide()
	anim.play("special_match")
	special_type = special
	
	match special:
		Specials.Type.ROW: texture = row_texture
		Specials.Type.COL: texture = col_texture
		Specials.Type.BOMB: texture = bomb_texture
		Specials.Type.COLOR_BOMB: back_color.show()
	
	sprite.texture = texture
