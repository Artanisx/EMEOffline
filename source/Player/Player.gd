extends Area2D

onready var _space_dust = $Camera2D/SpaceDust

var target_pos: Vector2 = Vector2.ZERO
var rotation_tween : Tween = Tween.new()
var movement_tween : Tween = Tween.new()
var duration = 0
export var movement_speed = 500
export var warp_movement_speed = 5000
var rotation_duration = 0
## Duration time for a quick rotation
export var quick_rotation_duration = 0.5
## Duration time for a slow rotation
export var slow_rotation_duration = 2
## Rotation degrees threshold to switch from quick to slow rotation
export var rotation_thershold = 50
export var low_distance_rotation_duration = 1
## How many times the movement_speed is to be considered a long distance voyage
export var low_distance_scalar = 2
## How far should a celestial be to be warpable
export var warp_threashold = 5000
var last_position: Vector2 = Vector2.ZERO
var regular_speed = 0
var warp_move_action: bool = false

signal movement_completed

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
var player_mining_laser_range: int = 500
var player_mining_laser_yield: int = 100

# Player velocity vector
var first_target_set = false

# This will offset any movement by this amount, stopping before it's reached. WIth a 0 it reaches dead center of the target global position
export var offset_distance: float = 100

func _ready() -> void:
	## Add the two tweens needed for rotation and movement
	add_child(rotation_tween)
	rotation_tween.connect("tween_all_completed", self, "_on_rotation_tween_completed")		
	add_child(movement_tween)	
	movement_tween.connect("tween_all_completed", self, "_on_movement_tween_completed")	

func _process(delta):
	_space_dust.global_position = global_position		
	calculate_instant_velocity(delta)	

func calculate_offset_target_position(target_pos: Vector2) -> Vector2:	
	# Check if there's an offset set
	if offset_distance > 0:
		# There's an offset
		var direction = (self.global_position - target_pos).normalized()
				
		return target_pos + direction * offset_distance
	else:
		return target_pos			
								

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
	
func face(target_pos: Vector2, is_this_warp_action: bool = false) -> void:	
	if (is_this_warp_action == true):
		warp_move_action = true
	else:
		warp_move_action = false
	
	# stop current rotation
	rotation_tween.remove_all()
	
	# stop current movement
	movement_tween.remove_all()
	
	# vector from the ship to the target
	var v = target_pos - self.global_position		
		
	# get the angle of that vector
	var angle = v.angle()	
	angle = rad2deg(angle)	
	
	var real_rotation = abs(global_rotation_degrees-angle)
	#print(str(real_rotation))	
	
	# Check if rotation is small
	if (real_rotation <= rotation_thershold):
		rotation_duration = quick_rotation_duration
		#print("Quick rotation")
	else:
		rotation_duration = slow_rotation_duration
		#print("slow rotation")
	
	
	rotation_tween.interpolate_property(self, "rotation_degrees", global_rotation_degrees, angle, rotation_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	rotation_tween.start()	

func move(target_pos: Vector2) -> void:	
	# stop current movement
	movement_tween.remove_all()
	
	# Calcualte the offset
	target_pos = calculate_offset_target_position(target_pos)
	
	# Calculate the duration the total movement should take
	# The duration should be distance / velocity
	var distance_vector = global_position - target_pos
	var distance = distance_vector.length()	
	
	# NORMAL MOVE ACTION
	if (warp_move_action == false):	
		print("moving")
		# If the distance is at least the movement_speed * low_distance_scalar (i.e. distance*2) ...
		if (movement_speed * low_distance_scalar  <= distance):
			# Distance is enough that we can calculate it 
			duration = distance / movement_speed
			movement_tween.interpolate_property(self, "position", global_position, target_pos, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		else:
			# Distance is quite low, set a low dur
			duration = low_distance_rotation_duration
			movement_tween.interpolate_property(self, "position", global_position, target_pos, duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)		
	else:
		# This is a WARP action
		print("warping")
		duration = distance / warp_movement_speed
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

## Emit warp particles
func warping(is_warping: bool):
	$Camera2D/WarpDust.enable_warp_dust(is_warping)	

## CALLBACKS
func _on_rotation_tween_completed() -> void:	
	move(target_pos)	
	
func _on_movement_tween_completed() -> void:	
	emit_signal("movement_completed")
