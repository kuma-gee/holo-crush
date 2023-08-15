extends Node

signal points_added(curr, added)

var _logger = Logger.new("Points")

var points := 0
var scored_points := 0

func scored(p):
	scored_points = p * 0.05
	_logger.debug("Scored %s points" % scored_points)

func add_scored_points():
	if scored_points <= 0:
		return
	
	points_added.emit(points, scored_points)
	points += scored_points
	_logger.debug("Adding scored to points %s" % points)

func get_points():
	return points
	
func set_points(p):
	points = p
