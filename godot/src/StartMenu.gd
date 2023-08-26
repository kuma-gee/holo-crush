extends MenuSystem

@export var settings: Control
@export var store: Control

func _ready():
	super._ready()
	settings.hide()
	settings.close.connect(func(): _hide_node(settings))
	
	store.hide()
	store.close.connect(func(): _hide_node(store))

func _on_store_pressed():
	_show_node(store)

func _on_settings_pressed():
	_show_node(settings)
