extends Node2D

var current_rails: Node2D
var next_rails: Node2D

var current_rails_progress := 0.0


func _get_colliding_rails_of_area(area: Area2D):
	var all_areas = area.get_overlapping_areas()
	
	for area in all_areas:
		if area.get_parent().is_in_group("Rails"):
			return area.get_parent()


func get_current_rails():
	return _get_colliding_rails_of_area($CurrentRailsArea)


func get_next_rails():
	return _get_colliding_rails_of_area($FutureRailsArea)


func _set_position_for_rails(rails_node):
	position = rails_node.position + rails_node.get_node("MovementPath").curve.interpolate(0, current_rails_progress)


func _process(delta):
	# For the first launch: get the current rail as soon as it's available; if it isn't, return
	# (For some reason it can take 1 frame until the rail is found)
	if not current_rails:
		current_rails = get_current_rails()
		
		if not current_rails:
			return
	
	if current_rails_progress >= 1.0:
		current_rails = get_next_rails()
		current_rails_progress -= 1.0
	
	_set_position_for_rails(current_rails)
	
	current_rails_progress += delta
