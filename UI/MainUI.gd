extends CanvasLayer


export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

export(NodePath) var train_stations_path
onready var train_stations = get_node(train_stations_path)

var current_train_station_id = 0
onready var current_train_station = train_stations.get_child(current_train_station_id)

var processing = true


func _get_next_train_station():
	current_train_station_id += 1
	if current_train_station_id < train_stations.get_child_count():
		current_train_station = train_stations.get_child(current_train_station_id)
	else:
		$PlayerArrow.visible = false
		processing = false


func _process(delta):
	if processing:
		# Position the PlayerArrow where the current train station is, but keep it on the screen by clamping
		var player_to_train = current_train_station.position - player_node.position
		var rotated = player_to_train.rotated(-player_node.rotation + PI/2)
		var in_normalized_rect = Vector2(clamp(rotated.x, -30, 29), clamp(rotated.y, -30, 29))
		
		# Disable the arrow if the player is close enough
		if player_to_train.length() < 10:
			_get_next_train_station()
		elif player_to_train.length() < 20:
			$PlayerArrow.visible = false
		elif player_to_train.length() < 40:
			$PlayerArrow.rect_position = in_normalized_rect + Vector2(22, 30)
			$PlayerArrow.rect_rotation = 90
		else:
			$PlayerArrow.visible = true
			
			$PlayerArrow.rect_position = in_normalized_rect + Vector2(30, 30)
			
			# Also rotate the arrow accordingly
			if in_normalized_rect.x > 0:
				$PlayerArrow.rect_rotation = 90
			else:
				$PlayerArrow.rect_rotation = -90
