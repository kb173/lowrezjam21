extends Node2D


func _ready():
	for child in get_children():
		child.connect("finished", self, "_play_random_track")
	
	_play_random_track()


func _play_random_track():
	var track_id = randi() % get_child_count()
	
	var child = get_child(track_id)#
	print(child.name)
	
	child.play()
