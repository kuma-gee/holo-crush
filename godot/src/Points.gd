extends Node

signal points_changed(curr, diff)

var _logger = Logger.new("Points")

var points := 0 : set = _set_points
var scored_points := 0

func _set_points(p):
	var diff = p - points
	points_changed.emit(points, diff)
	points = p

func scored(p):
	scored_points += p * 0.05
	_logger.debug("Scored %s points" % scored_points)

func add_scored_points():
	if scored_points <= 0:
		return
	
	self.points += scored_points
	scored_points = 0
	_logger.debug("Adding scored to points %s" % points)

func get_points():
	return points
	
func set_points(p):
	points = p

func use_points(p):
	if points < p:
		return false
	
	self.points -= p
	return true
