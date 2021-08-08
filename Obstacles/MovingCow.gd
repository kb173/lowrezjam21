extends Node2D


enum MoveDirection {
	LEFT,
	RIGHT
}


export var cow_speed := 8.0
export(MoveDirection) var direction

var cow_movement := 0.0
var moving := false


func _ready():
	$MoveBeginArea.connect("area_entered", self, "_on_move_area_entered")
	
	if direction == MoveDirection.RIGHT:
		$Cow/Sprite.flip_h = true


func _on_move_area_entered(other_area):
	if other_area.is_in_group("Player"):
		moving = true


func _process(delta):
	if moving:
		var direction_multiplier = 1 if direction == MoveDirection.RIGHT else -1
			
		$Cow.position += Vector2(delta * cow_speed * direction_multiplier, 0)
