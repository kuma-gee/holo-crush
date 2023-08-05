# https://www.reddit.com/r/godot/comments/nimkqg/how_to_break_a_2d_sprite_in_a_cool_and_easy_way/
extends Node2D

signal deleted()

@export var SHARD: PackedScene

@export var nbr_of_shards = 20 #sets the number of break points
@export var threshhold = 10.0 #prevents slim triangles being created at the sprite edges
@export var min_impulse = 50.0 #impuls of the shards upon breaking
@export var max_impulse = 200.0
@export var lifetime = 5.0 #lifetime of the shards
@export var display_triangles = false #debugging: display sprite triangulation

var triangles = []
var shards = []

func _ready() -> void:
	if get_parent() is Sprite2D:
		var _rect = get_parent().get_rect()
		var points = []
		#add outer frame points
		points.append(_rect.position)
		points.append(_rect.position + Vector2(_rect.size.x, 0))
		points.append(_rect.position + Vector2(0, _rect.size.y))
		points.append(_rect.end)

		#add random break points
		for i in nbr_of_shards:
			var p = _rect.position + Vector2(randf_range(0, _rect.size.x), randf_range(0, _rect.size.y))
			#move outer points onto rectangle edges
			if p.x < _rect.position.x + threshhold:
				p.x = _rect.position.x
			elif p.x > _rect.end.x - threshhold:
				p.x = _rect.end.x
			if p.y < _rect.position.y + threshhold:
				p.y = _rect.position.y
			elif p.y > _rect.end.y - threshhold:
				p.y = _rect.end.y
			points.append(p)

		#calculate triangles
		var delaunay = Geometry2D.triangulate_delaunay(points)
		for i in range(0, delaunay.size(), 3):
			triangles.append([points[delaunay[i + 2]], points[delaunay[i + 1]], points[delaunay[i]]])

		#create RigidBody2D shards
		var texture = get_parent().texture
		for t in triangles:
			var p1 = t[0]
			var p2 = t[1]
			var p3 = t[2]
			var center = Vector2((p1.x + p2.x + p3.x)/3.0,(p1.y + p2.y + p3.y)/3.0)

			var shard = SHARD.instantiate()
			shard.position = center
			shard.hide()
			shards.append(shard)

			#setup polygons & collision shapes
			shard.get_node("Polygon2D").texture = texture
			shard.get_node("Polygon2D").polygon = t
			shard.get_node("Polygon2D").position = -center
			shard.get_node("Polygon2D").texture_offset = _rect.size/2

			#shrink polygon so that the collision shapes don't overlapp
			var shrunk_triangles = Geometry2D.offset_polygon(t, -2)
			if shrunk_triangles.size() > 0:
				shard.get_node("CollisionPolygon2D").polygon = shrunk_triangles[0]
			else:
				shard.get_node("CollisionPolygon2D").polygon = t
			shard.get_node("CollisionPolygon2D").position = -center

		queue_redraw()
		call_deferred("add_shards")


func add_shards() -> void:
	for s in shards:
		get_parent().add_child(s)


func shatter() -> void:
	randomize()
	get_parent().self_modulate.a = 0
	for s in shards:
		var direction = Vector2.UP.rotated(randf_range(0, TAU))
		var impulse = randf_range(min_impulse, max_impulse)
		s.freeze = false
		s.apply_central_impulse(direction * impulse)
		s.get_node("CollisionPolygon2D").disabled = false
		s.show()
	$DeleteTimer.start(lifetime)

func _draw() -> void:
	if display_triangles:
		for i in triangles:
			draw_line(i[0], i[1], Color.WHITE, 1)
			draw_line(i[1], i[2], Color.WHITE, 1)
			draw_line(i[2], i[0], Color.WHITE, 1)


func _on_delete_timer_timeout():
	deleted.emit()
	get_parent().queue_free()
