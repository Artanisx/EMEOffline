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
export var sun_damage = 10
var last_position: Vector2 = Vector2.ZERO
var regular_speed = 0
var warp_move_action: bool = false

signal movement_completed
signal death
signal hurt

# PLAYER ACCOUNT STATS
enum MINING_LASER {MINING_LASER_I = 1, MINING_LASER_II = 2, MINING_LASER_III = 3, MINING_LASER_IV = 4, MINING_LASER_V = 5}
enum CARGO_EXTENDER {NO_CARGO_EXTENDER = 0, CARGO_EXTENDER_I = 1, CARGO_EXTENDER_II = 2, CARGO_EXTENDER_III = 3, CARGO_EXTENDER_IV = 4, CARGO_EXTENDER_V = 5}

var player_credits: int = 0
var player_mining_laser: int = 1
var player_cargo_extender: int = 0
var player_cargo_hold: int = 0
var player_cargo_hold_capacity: int = 1000
var player_hull_integrity: int = 1000 
var player_top_speed: int = 100	# unused yet

const base_cargo_hold: int = 1000

# MINING LASER STAT
var player_mining_laser_cycle: float = 5
var player_mining_laser_range: int = 100
var player_mining_laser_yield: int = 100

# Player velocity vector
var first_target_set = false

# This will offset any movement by this amount, stopping before it's reached. WIth a 0 it reaches dead center of the target global position
export var offset_distance: float = 100

## DEBUG
var god_mode: bool = false

func restore_regular_offset() -> void:
	offset_distance = 100

func _ready() -> void:
	## Add the two tweens needed for rotation and movement
	add_child(rotation_tween)
	var err1 = rotation_tween.connect("tween_all_completed", self, "_on_rotation_tween_completed")		
	add_child(movement_tween)	
	var err2 = movement_tween.connect("tween_all_completed", self, "_on_movement_tween_completed")	
	
	if err1 != OK or err2 != OK:
		printerr("Error while connecting the signal!")

func _process(delta):
	_space_dust.global_position = global_position		
	calculate_instant_velocity(delta)	
	check_collisions()
	
func check_collisions() -> void:
	# Check for anomalies collision for damaging purposes
	for body in get_overlapping_bodies():
		if body.is_in_group("anomalies"):
			damage_player(body)
			
	# check collision with sun
	for body in get_overlapping_bodies():
		if body.is_in_group("star"):			
			damage_player_by_star()

func damage_player_by_star() -> void:
	if god_mode:
		return
	
	player_hull_integrity -= sun_damage
				
	if (player_hull_integrity <= 0):
		player_death()	
	else:
		emit_signal("hurt")	
		
func damage_player(node):
	if god_mode:
		return
				
	var damage = node.get_touch_damage()
	player_hull_integrity -= damage	
	
	if (player_hull_integrity <= 0):
		player_death()	
	else:
		emit_signal("hurt")	
		
func player_death() -> void:
	print("I'm dead")
	emit_signal("death")
	# Stop collision and hide (TEMP)
	$CollisionShape2D.disabled = true
	hide()	

# Set the correct mining laser stats, following the installed mining laser
func set_mining_laser():
	match player_mining_laser:
		1:
			player_mining_laser_cycle = 5
			player_mining_laser_range = 500
			player_mining_laser_yield = 100
		2:
			player_mining_laser_cycle = 5
			player_mining_laser_range = 500
			player_mining_laser_yield = 150
		3:
			player_mining_laser_cycle = 5
			player_mining_laser_range = 500
			player_mining_laser_yield = 300
		4:
			player_mining_laser_cycle = 2.5
			player_mining_laser_range = 1000
			player_mining_laser_yield = 200
		5:
			player_mining_laser_cycle = 2
			player_mining_laser_range = 1000
			player_mining_laser_yield = 400

# Set the correct cargo stats, following the installed cargo extender
func set_cargo_ext():
	match player_cargo_extender:
		0:
			player_cargo_hold_capacity = base_cargo_hold			
		1:
			player_cargo_hold_capacity = base_cargo_hold + 1000			
		2:
			player_cargo_hold_capacity = base_cargo_hold + 2000
		3:
			player_cargo_hold_capacity = base_cargo_hold + 4000
		4:
			player_cargo_hold_capacity = base_cargo_hold + 6000
		5:
			player_cargo_hold_capacity = base_cargo_hold + 9000

func calculate_offset_target_position(real_target_pos: Vector2) -> Vector2:	
	# Check if there's an offset set
	if offset_distance > 0:
		# There's an offset
		var direction = (self.global_position - target_pos).normalized()
				
		return real_target_pos + direction * offset_distance
	else:
		return real_target_pos			
								

func calculate_instant_velocity(_delta: float) -> void:
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
	
func face(face_target_pos: Vector2, is_this_warp_action: bool = false) -> void:	
	if (is_this_warp_action == true):
		warp_move_action = true
	else:
		warp_move_action = false
	
	# stop current rotation
	var err1 = rotation_tween.remove_all()
	
	# stop current movement
	var err2 = movement_tween.remove_all()
	
	if (err1 != true or err2 != true):
		printerr("Error removing tweens!")
	
	# vector from the ship to the target
	var v = face_target_pos - self.global_position		
		
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
	
	
	var err3 = rotation_tween.interpolate_property(self, "rotation_degrees", global_rotation_degrees, angle, rotation_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	var err4 = rotation_tween.start()	
	
	if (err3 != true or err4 != true):
		printerr("Error while rotating.")

func move(move_target_pos: Vector2) -> void:	
	# stop current movement
	var err = movement_tween.remove_all()
	
	if (err != true):
		printerr("Error while removing movement tween.")
	
	# Calcualte the offset
	move_target_pos = calculate_offset_target_position(move_target_pos)
	
	# Clamp it so it doesn't go outside the map
	move_target_pos.x = clamp(move_target_pos.x, -30000, 28600)	
	move_target_pos.y = clamp(move_target_pos.y, -30214, 28881)
	
	# Calculate the duration the total movement should take
	# The duration should be distance / velocity
	var distance_vector = global_position - move_target_pos
	var distance = distance_vector.length()	
	
	# NORMAL MOVE ACTION
	if (warp_move_action == false):	
		print("moving")
		# If the distance is at least the movement_speed * low_distance_scalar (i.e. distance*2) ...
		if (movement_speed * low_distance_scalar  <= distance):
			# Distance is enough that we can calculate it 
			duration = distance / movement_speed
			var _err2 = movement_tween.interpolate_property(self, "position", global_position, move_target_pos, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		else:
			# Distance is quite low, set a low dur
			duration = low_distance_rotation_duration
			var _err3 = movement_tween.interpolate_property(self, "position", global_position, move_target_pos, duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)		
	else:
		# This is a WARP action
		print("warping")
		duration = distance / warp_movement_speed
		var _err4 = movement_tween.interpolate_property(self, "position", global_position, move_target_pos, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		
	var _err5 = movement_tween.start()	

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
	set_mining_laser()	
	set_cargo_ext()

## Emit warp particles
func warping(is_warping: bool):
	$Camera2D/WarpDust.enable_warp_dust(is_warping)	

## CALLBACKS
func _on_rotation_tween_completed() -> void:	
	move(target_pos)	
	
func _on_movement_tween_completed() -> void:	
	emit_signal("movement_completed")
