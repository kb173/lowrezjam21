extends Node2D

var last_track_id = 2


func _ready():
	randomize()
	
	for child in get_children():
		child.connect("finished", self, "_play_random_track")
	
	_play_random_track()


func _play_random_track():
	var track_id = randi() % get_child_count()
	
	# FIXME: This could theoretically stall forever
	while track_id == last_track_id:
		track_id = randi() % get_child_count()
	
	var child = get_child(track_id)#
	
	child.play()
	
	last_track_id = track_id
