extends KinematicBody2D

class_name SpaceAnomaly

export var rotation_speed: float = 0.2
export var touch_damage: int = 5
export var anomaly_speed: int = 100

var player: Node = null

var velocity: Vector2 = Vector2.ZERO

signal damage

func _ready() -> void:
	# Get player node
	player = get_node("/root/GameWorld/Player")

func _process(delta):
	rotation += rotation_speed * delta
	movement(delta)	
	
func movement(_delta):
	# Chase player
	velocity = Vector2.ZERO
	
	if player:
		velocity = position.direction_to(player.position) * anomaly_speed
	
	velocity = move_and_slide(velocity)	

func get_touch_damage() -> int:
	return touch_damage
