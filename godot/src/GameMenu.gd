extends MenuSystem

@export var settings: Control
@export var gameover: Control

func _ready():
	super._ready()
	gameover.hide()
	
	settings.hide()
	settings.close.connect(func(): _hide_node(settings))


func show_gameover():
	_show_node(gameover)


func _on_settings_pressed():
	_show_node(settings)
