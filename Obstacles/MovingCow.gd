extends Node2D


enum MoveDirection {
	LEFT,
	RIGHT
}


export var cow_speed := 8.0
export(MoveDirection) var direction

var cow_movement := 0.0
var moving := false

onready var initial_position = global_position

var cow_scene = preload("res://Obstacles/Cow.tscn")


func _ready():
	$MoveBeginArea.connect("area_entered", self, "_on_move_area_entered")
	
	if direction == MoveDirection.RIGHT:
		$Cow/Sprite.flip_h = true


func _on_move_area_entered(other_area):
	if other_area.is_in_group("Player"):
		$Cows.add_child(cow_scene.instance())


func _process(delta):
	for cow in $Cows.get_children():
		var direction_multiplier = 1 if direction == MoveDirection.RIGHT else -1
			
		cow.position += Vector2(delta * cow_speed * direction_multiplier, 0)
