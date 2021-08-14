extends Node2D

var last_track_id = 2


func _ready():
	randomize()
	
	for child in $MoveAudio.get_children():
		child.connect("finished", self, "_play_random_move_track")
	
	_play_random_move_track()


func _play_random_move_track():
	var track_id = randi() % $MoveAudio.get_child_count()
	
	# FIXME: This could theoretically stall forever
	while track_id == last_track_id:
		track_id = randi() % $MoveAudio.get_child_count()
	
	var child = $MoveAudio.get_child(track_id)
	
	child.play()
	
	last_track_id = track_id


func play_crash():
	$CrashAudio.play()


func play_ambience():
	for move_child in $MoveAudio.get_children():
		move_child.volume_db = -INF
	
	if not $StationAudio.playing:
		$StationAudio.play(randf() * $StationAudio.stream.get_length())
	
	$StationAudio.volume_db = 0.0


func play_transition():
	if not $StationAudio.playing:
		$StationAudio.play(randf() * $StationAudio.stream.get_length())
	
	for move_child in $MoveAudio.get_children():
		move_child.volume_db = -5.0
	
	$StationAudio.volume_db = -5.0


func play_moving():
	for move_child in $MoveAudio.get_children():
		move_child.volume_db = 0.0
	
	$StationAudio.stop()
