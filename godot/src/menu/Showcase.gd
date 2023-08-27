extends Overlay

const PIECE_TEX = {
	Piece.Type.GURA: preload("res://assets/gacha/Myth_Gura.png")
}

@export var tex: TextureRect
@export var overlay: ColorRect
@export var shine: ColorRect

var tw: TweenCreator

func _ready():
	tw = TweenCreator.create(self)
	
	hide()
	on_hide.connect(func():
		if tw.new_tween(func(): hide()):
			tw.fade_out(overlay)
			tw.fade_out(shine).set_ease(Tween.EASE_OUT)
			tw.scale_out(tex)
	)

func show_piece(piece):
	if tw.new_tween():
		if piece in PIECE_TEX:
			tex.texture = PIECE_TEX[piece]
		
		tw.fade_in(overlay)
		tw.fade_in(shine).set_ease(Tween.EASE_IN)
		tw.scale_in(tex)
		show()
