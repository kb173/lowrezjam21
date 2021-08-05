extends Node2D

var current_rail: Node2D
var next_rail: Node2D

var current_rail_progress := 0.0


func get_current_rail():
	var all_areas = $CurrentRailsArea.get_overlapping_areas()
	
	for area in all_areas:
		if area.get_parent().is_in_group("Rails"):
			current_rail = area.get_parent()
	

func get_next_rail():
	var all_areas = $FutureRailsArea.get_overlapping_areas()
	
	for area in all_areas:
		print(area.get_parent().name)
		if area.get_parent().is_in_group("Rails"):
			current_rail = area.get_parent()


func _process(delta):
	# Mainly for the first launch
	if not current_rail:
		get_current_rail()
	
	position = current_rail.position + current_rail.get_node("MovementPath").curve.interpolate(0, current_rail_progress)
	
	current_rail_progress += delta

	if current_rail_progress >= 1.0:
		get_next_rail()
		current_rail_progress -= 1.0
