extends MenuSystem

@export var settings: Control
@export var store: Control
@export var collection: Control

func _ready():
	super._ready()
	settings.hide()
	settings.close.connect(func(): _hide_node(settings))
	
	store.hide()
	store.close.connect(func(): _hide_node(store))
	
	collection.hide()
	collection.close.connect(func(): _hide_node(collection))

func _on_store_pressed():
	_show_node(store)

func _on_settings_pressed():
	_show_node(settings)

func _on_collection_pressed():
	_show_node(collection)
