extends Control

@export var pack_container: Control
@export var showcase_container: Control

@onready var showcase := $Showcase
@onready var store_container := $PanelContainer
@onready var anim := $AnimationPlayer

var showing_showcase = false

func _ready():
	store_container.hide()
	showcase.hide()
	
	for child in pack_container.get_children():
		child.pressed.connect(func(): _unpack_gacha(child))

func _on_store_pressed():
	if store_container.visible:
		store_container.hide()
		showcase.hide()
	else:
		store_container.show()

func _unpack_gacha(pack: GachaPack):
	if GameManager.points.use_points(pack.price):
		var new_piece = pack.get_pieces().pick_random()
		GameManager.unlock_piece(new_piece)
		print("unlocked %s" % Piece.Type.keys()[new_piece])
		showcase_container.pivot_offset = showcase_container.size / 2
		anim.play("showcase")
		await anim.animation_finished
		showing_showcase = true
	else:
		print("No money")

func _on_showcase_on_hide():
	if not showing_showcase:
		return
		
	anim.play_backwards("showcase")
	await anim.animation_finished
	showcase.hide()
	showing_showcase = false
