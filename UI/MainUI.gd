extends CanvasLayer


export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

export(NodePath) var current_train_station_node
onready var current_train_station = get_node(current_train_station_node)


func _process(delta):
	# Position the PlayerArrow where the current train station is, but keep it on the screen by clamping
	var player_to_train = current_train_station.position - player_node.position
	var rotated = player_to_train.rotated(-player_node.rotation + PI/2)
	var in_normalized_rect = Vector2(clamp(rotated.x, -30, 29), clamp(rotated.y, -30, 29))
	
	$PlayerArrow.rect_position = in_normalized_rect + Vector2(30, 30)
