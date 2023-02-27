extends KinematicBody2D

class_name SpaceAnomaly

export var rotation_speed: float = 0.2
export var touch_damage: int = 3
export var anomaly_speed: int = 100
export var anomaly_detection_range: int = 2500 #player must be inside this range for the anomaly to actually move around
export var anomaly_random_area_range: int = 1000
export var anomaly_target_reach_offset: int = 25
export var random_movement_chance: int = 40

var player: Node = null
var world: Node = null
var velocity: Vector2 = Vector2.ZERO
var random_position_reached: bool = false
var current_target_position: Vector2 = Vector2.ZERO

signal chasing

func _ready() -> void:
	# Get player node
	player = get_node("/root/GameWorld/Player")	
	
	# Get the main scene node
	world = get_node("/root/GameWorld")	
	
	# Connect the chasing signal
	connect("chasing", world, "_on_space_anomaly_chasing")
	
	# Seeds RNG
	randomize()
	
	# Set first randomized position
	current_target_position = get_random_position()

func _process(delta):
	rotation += rotation_speed * delta
	movement(delta)	
	check_position_reached()
	
func movement(_delta):	
	velocity = Vector2.ZERO
	
	# Calculate distance from the player
	var distance = int(round(player.position.distance_to(self.position)))	
	
	# Chase player if it is in range
	if player and distance >= anomaly_detection_range:
		# PLayer is too far away so the anomaly shouldn't move		
		## Old chase player current position code
		#velocity = position.direction_to(player.position) * anomaly_speed
		velocity = Vector2.ZERO				
	else:
		# player is in range, so the anomaly should start moving somewhere
		velocity = position.direction_to(current_target_position) * anomaly_speed	
	
	velocity = move_and_slide(velocity)	
	
func chase_or_random() -> bool:
	var roll = rand_range(1, 100)
	
	if roll >= random_movement_chance:
		print("Anomaly decided to chase player. ROLL= " + str(roll))
		return true
	else:
		print("Anomaly decided to move randomly. ROLL= " + str(roll))
		return false
	

func check_position_reached() -> void:	
	# If the anomaly reached its destiation, choose a new one
	var distance = int(round(current_target_position.distance_to(self.position)))	
	
	# Basically reached it...
	if (distance <= anomaly_target_reach_offset):		
		# Select wheter it should now chase the player or get another random position
		if (!chase_or_random()):
			current_target_position = get_random_position()
			print("Anomaly has reached it's target, selecting anew one: " + str(current_target_position))
		else:
			#it should chase the player instead
			#or rather it should go towards the player not really chase him
			current_target_position = player.position
			print("Anomaly has targetted the player!")
			emit_signal("chasing")

func get_random_position() -> Vector2:	
	# set an area around tot px  from the anomaly
	var min_x = self.position.x - anomaly_random_area_range
	var max_x = self.position.x + anomaly_random_area_range
	var min_y = self.position.y - anomaly_random_area_range
	var max_y = self.position.y + anomaly_random_area_range
	
	var random_position = Vector2(rand_range(min_x, max_x), rand_range(min_y, max_y))	
	return random_position

func get_touch_damage() -> int:
	return touch_damage
