extends Node2D


# The player traverses move_speed tiles per second
export var move_speed := 2.0

var last_rails := []
var current_rails: Node2D
var next_rails: Node2D

var moving := true

export(NodePath) var initial_last_rails
onready var last_set_rails: Node2D = get_node(initial_last_rails)
onready var last_set_direction = Direction.STRAIGHT

var current_rails_progress := 0.0
var current_move_speed = move_speed

var last_checkpoint

enum Direction {
	STRAIGHT,
	LEFT,
	RIGHT
}

var rails_scenes = {
	Direction.STRAIGHT: preload("res://Rails/RailsStraight.tscn"),
	Direction.LEFT: preload("res://Rails/RailsLeft.tscn"),
	Direction.RIGHT: preload("res://Rails/RailsRight.tscn")
}

class Checkpoint:
	var position
	var rotation
	var placed_since_here = []
	var last_rails = []
	var current_rails
	var next_rails
	var last_set_rails
	var last_set_direction
	
	func _init(position, rotation, current_rails, next_rails, last_rails, last_set_rails, last_set_direction):
		self.position = position
		self.rotation = rotation
		self.current_rails = current_rails
		self.next_rails = next_rails
		self.last_rails = last_rails
		self.last_set_rails = last_set_rails
		self.last_set_direction = last_set_direction



func _ready():
	$CurrentRailsArea.connect("area_entered", self, "_on_current_area_entered")
	
	# Initial next rail probe placement
	$TransformReset/NewRailsProbe.global_position = _get_new_rails_position()


func _on_current_area_entered(other):
	if other.is_in_group("TrainStopper"):
		# Stop at train stations
		moving = false
		$TrainAudio.play_ambience()
		create_new_checkpoint()
		
		yield(get_tree().create_timer(5.0), "timeout")
		
		moving = true
		$TrainAudio.play_transition()
	elif other.is_in_group("TrainSlower"):
		current_move_speed = move_speed / 2.0
		$TrainAudio.play_transition()
	elif other.is_in_group("TrainFaster"):
		current_move_speed = move_speed
		$TrainAudio.play_moving()
	elif other.is_in_group("LoseArea"):
		lose()

func _get_new_rails_position() -> Vector2:
	var position_local = last_set_rails.get_node("NewRailOrigin").position
	
	if last_set_direction == Direction.RIGHT:
		position_local += Vector2(4, 0)
	elif last_set_direction == Direction.LEFT:
		position_local += Vector2(-4, 0)
	else:
		position_local += Vector2(0, -4)
	
	return last_set_rails.to_global(position_local)


func _get_new_rails_rotation() -> float:
	var new_rotation = last_set_rails.rotation
	
	if last_set_direction == Direction.LEFT:
		new_rotation -= PI / 2.0
	elif last_set_direction == Direction.RIGHT:
		new_rotation += PI / 2.0
	
	return new_rotation


func _instance_new_rails(direction):
	var new_rails = rails_scenes[direction].instance()
	
	new_rails.position = _get_new_rails_position()
	new_rails.rotation = _get_new_rails_rotation()
	
	get_parent().add_child(new_rails)
	last_checkpoint.placed_since_here.append(new_rails)
	
	last_set_rails = new_rails
	last_set_direction = direction
	
	# Probe at the point of the next rails for whether something can be placed there
	$TransformReset/NewRailsProbe.global_position = _get_new_rails_position()


func _can_set_rails():
	var probe_overlaps = $TransformReset/NewRailsProbe.get_overlapping_areas()
	
	for area in probe_overlaps:
		if area.is_in_group("RailBlocker"):
			return false
	
	return true


func _input(event):
	if _can_set_rails():
		if event.is_action_pressed("set_straight"):
			_instance_new_rails(Direction.STRAIGHT)
		
		elif event.is_action_pressed("set_right"):
			_instance_new_rails(Direction.RIGHT)
		
		elif event.is_action_pressed("set_left"):
			_instance_new_rails(Direction.LEFT)


func _get_colliding_rails_of_area(area: Area2D):
	var all_areas = area.get_overlapping_areas()
	
	for area in all_areas:
		if area.get_parent().is_in_group("Rails"):
			return area.get_parent()


func get_current_rails():
	return _get_colliding_rails_of_area($CurrentRailsArea)


func get_next_rails():
	var future_rails = _get_colliding_rails_of_area($FutureRailsArea)
	if future_rails:
		return future_rails
	else:
		lose()
		return null


func lose():
	print("LOSE") # TODO
	moving = false
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	apply_last_checkpoint()
	yield(get_tree().create_timer(0.2), "timeout")
	
	moving = true


func create_new_checkpoint():
	last_checkpoint = Checkpoint.new(global_position, global_rotation, current_rails, next_rails, last_rails.duplicate(), last_set_rails, last_set_direction)


func apply_last_checkpoint():
	global_position = last_checkpoint.position
	global_rotation = last_checkpoint.rotation
	current_rails = last_checkpoint.current_rails
	next_rails = last_checkpoint.next_rails
	last_rails = last_checkpoint.last_rails
	last_set_rails = last_checkpoint.last_set_rails
	last_set_direction = last_checkpoint.last_set_direction
	
	$TransformReset/NewRailsProbe.global_position = _get_new_rails_position()
	
	for node in last_checkpoint.placed_since_here:
		node.queue_free()
	
	create_new_checkpoint()


func _get_position_for_rails(rails_node, interpolate_position):
	var curve = rails_node.get_node("MovementPath").curve
	var interpolated_point = curve.interpolate_baked(interpolate_position * curve.get_baked_length())
	
	return rails_node.position + interpolated_point.rotated(rails_node.rotation)


func _process(delta):
	if not moving: return
	
	if current_rails_progress >= 1.0:
		last_rails.push_front(current_rails)
		
		current_rails = get_next_rails()
		if current_rails:
			current_rails_progress -= 1.0
	
	# For the first launch (and end): get the current rail as soon as it's available; if it isn't, return
	# (For some reason it can take 1 frame until the rail is found)
	if not current_rails:
		current_rails = get_current_rails()
		
		if not current_rails:
			return
	
	# Update position and rotation
	position = _get_position_for_rails(current_rails, current_rails_progress)
	
	if current_rails_progress < 0.99:
		rotation = position.angle_to_point(_get_position_for_rails(current_rails, current_rails_progress + 0.1))
	
	# Same for wagons
	if last_rails.size() >= $Wagons.get_child_count():
		var wagon_index = 0
		for wagon in $Wagons.get_children():
			var wagon_rails = last_rails[wagon_index]
			
			wagon.global_position = _get_position_for_rails(wagon_rails, current_rails_progress)
			wagon.global_rotation = -PI/2 + wagon.global_position.angle_to_point(_get_position_for_rails(wagon_rails, current_rails_progress + 0.1))
			
			wagon_index += 1
	
	current_rails_progress += delta * current_move_speed
	
	# Relevant for the end of the first frame
	if not last_checkpoint:
		create_new_checkpoint()
