extends Area2D

onready var _space_dust = $Camera2D/SpaceDust

var target_pos: Vector2 = Vector2.ZERO
var rotation_tween : Tween = Tween.new()
var movement_tween : Tween = Tween.new()
var duration = 0
export var movement_speed = 500
export var rotation_duration = 1
var last_position: Vector2 = Vector2.ZERO
var regular_speed = 0

# PLAYER ACCOUNT STATS
enum MINING_LASER {MINING_LASER_I = 1, MINING_LASER_II = 2, MINING_LASER_III = 3, MINING_LASER_IV = 4, MINING_LASER_V = 5}
enum CARGO_EXTENDER {NO_CARGO_EXTENDER = 0, CARGO_EXTENDER_I = 1, CARGO_EXTENDER_II = 2, CARGO_EXTENDER_III = 3, CARGO_EXTENDER_IV = 4, CARGO_EXTENDER_V = 5}

var player_credits: int = 0
var player_mining_laser: int = 0
var player_cargo_extender: int = 0
var player_cargo_hold: int = 0
var player_cargo_hold_capacity: int = 1000 # unused yet
var player_hull_integrity: int = 1000 # unused yet
var player_top_speed: int = 100	# unused yet

# MINING LASER STAT
var player_mining_laser_cycle: int = 5
var player_mining_laser_range: int = 15
var player_mining_laser_yield: int = 100

# Player velocity vector
var first_target_set = false

func _ready() -> void:
	## Add the two tweens needed for rotation and movement
	add_child(rotation_tween)
	rotation_tween.connect("tween_all_completed", self, "_on_rotation_tween_completed")		
	add_child(movement_tween)	
	rotation_tween.connect("tween_all_completed", self, "_on_movement_tween_completed")	

func _process(delta):
	_space_dust.global_position = global_position	
	calculate_instant_velocity(delta)	

func calculate_instant_velocity(delta: float) -> void:
	var current_position = self.global_position		
	
	var instSpeed = (last_position-current_position).length()		
		
	# make it so that highest value matches speed in units and lowest min...	
	if instSpeed != 0:		
		regular_speed = map(instSpeed, 0, movement_speed/70.86, 0, movement_speed)
	
	last_position = current_position	

func get_instant_velocity() -> int:
	if int(round(regular_speed)) <= 5:
		return 0
	else:
		return int(round(regular_speed))

func map(value, start1, stop1, start2, stop2):
	return (value - start1) / (stop1 - start1) * (stop2 - start2) + start2

func face(target_pos: Vector2) -> void:		
	# PROBLEM: If there's no rotation needed (i.e. just a few degrees) it still takes the whole duration doing nothing
	# stop current rotation
	rotation_tween.remove_all()
	
	# stop current movement
	movement_tween.remove_all()
	
	# vector from the ship to the target
	var v = target_pos - self.global_position		
		
	# get the angle of that vector
	var angle = v.angle()	
	angle = rad2deg(angle)	
	
	rotation_tween.interpolate_property(self, "rotation_degrees", global_rotation_degrees, angle, rotation_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	rotation_tween.start()	

func move(target_pos: Vector2) -> void:	
	# PROBLEM: Something's off in calculations. If the distance is very small, it reaches max speed almost instantly. While long distance shows correct behaviour
	# stop current movement
	movement_tween.remove_all()
	
	# Calculate the duration the total movement should take
	# The duration should be distance / velocity
	var distance_vector = global_position - target_pos
	var distance = distance_vector.length()	
	duration = distance / movement_speed

	movement_tween.interpolate_property(self, "position", global_position, target_pos, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	movement_tween.start()	

func SetPlayer(cred: int, mining: int, cargoxt: int, cargoh: int, pos: Vector2) -> void:
	player_credits = cred
	
	match mining:
		1:
			player_mining_laser = MINING_LASER.MINING_LASER_I
		2:
			player_mining_laser = MINING_LASER.MINING_LASER_II
		3:
			player_mining_laser = MINING_LASER.MINING_LASER_III
		4:
			player_mining_laser = MINING_LASER.MINING_LASER_IV
		5:
			player_mining_laser = MINING_LASER.MINING_LASER_V
			
	match cargoxt:
		0:
			player_cargo_extender = CARGO_EXTENDER.NO_CARGO_EXTENDER
		1:
			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_I
		2:
			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_II
		3:
			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_III
		4:
			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_IV
		5:
			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_V
			
	player_cargo_hold = cargoh
	position = pos


## CALLBACKS
func _on_rotation_tween_completed() -> void:	
	move(target_pos)	
	
func _on_movement_tween_completed() -> void:	
	pass	
