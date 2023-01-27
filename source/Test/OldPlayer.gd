#extends Area2D
#
#export(String, "Direct", "RTS", "Turtle", "Missile") var movement_mode
#export var rotation_speed: float = PI
#export var speed: float = 100
#export var dead_zone: int = 5
#onready var target = position
#onready var _space_dust = $Camera2D/SpaceDust			
#
## PLAYER ACCOUNT STATS
#enum MINING_LASER {MINING_LASER_I = 1, MINING_LASER_II = 2, MINING_LASER_III = 3, MINING_LASER_IV = 4, MINING_LASER_V = 5}
#enum CARGO_EXTENDER {NO_CARGO_EXTENDER = 0, CARGO_EXTENDER_I = 1, CARGO_EXTENDER_II = 2, CARGO_EXTENDER_III = 3, CARGO_EXTENDER_IV = 4, CARGO_EXTENDER_V = 5}
#
#var player_credits: int = 0
#var player_mining_laser: int = 0
#var player_cargo_extender: int = 0
#var player_cargo_hold: int = 0
#var player_cargo_hold_capacity: int = 1000 # unused yet
#var player_hull_integrity: int = 1000 # unused yet
#var player_top_speed: int = 100	# unused yet
#
## MINING LASER STAT
#var player_mining_laser_cycle: int = 5
#var player_mining_laser_range: int = 15
#var player_mining_laser_yield: int = 100
#
## Player velocity vector
#var velocity := Vector2.ZERO
#var first_target_set = false
#
## TurtleExample
#const ARRIVE_DISTANCE := 500.0
#const ARRIVED_THRESHOLD := 100.0
#var max_speed := 1500.0
#var target_mouse_position = Vector2.ZERO
#
#func _process(delta):
#	_space_dust.global_position = global_position
#
#	if (movement_mode == "Direct"):		
#		position += velocity * delta
#	elif movement_mode == "Turtle":
#		if position.distance_to(target_mouse_position) < ARRIVED_THRESHOLD:
#			return			
#
#		var desired_velocity = position.direction_to(target_mouse_position) * max_speed
#
#		var distance_to_mouse = position.distance_to(target_mouse_position)
#
#		if distance_to_mouse < ARRIVE_DISTANCE:
#			desired_velocity *= distance_to_mouse / ARRIVE_DISTANCE
#
#		var steering = desired_velocity - velocity
#		velocity += steering / 32.0			
#
#		position += velocity * delta
#		rotation = velocity.angle()
#		print(velocity.length())
#	elif (movement_mode == "RTS" and first_target_set == true):
#		velocity = position.direction_to(target) * speed
#
#		## SMOOTH LOOKAT
#		# vector from the ship to the target
#		var v = target - self.global_position
#
#		# get the angle of that vector
#		var angle = v.angle()
#		var r = global_rotation
#
#		# ger toation allowed this frame
#		var angle_delta = rotation_speed * delta
#
#		#get complete rotation to target
#		angle = lerp_angle(r, angle, 1.0)
#
#		# limit that rotaiton to what is allowed this frame
#		angle = clamp(angle, r - angle_delta, r + angle_delta)
#
#		# set ship rotation
#		global_rotation = angle	
#
#		# Move only if the target is at least dead_zone units away and after the rotation to look at has finished		
#		if position.distance_to(target) > dead_zone and rotation == angle:
#			position += velocity * delta			
#		else:
#			velocity = Vector2.ZERO				
#
#		if velocity.x > 0:
#			_space_dust.direction("Left")
#		elif velocity.x < 0:
#			_space_dust.direction("Right")
#
#		print(velocity.length()/5)
#	elif (movement_mode == "Missile"):
#		var accelerat = position.direction_to(target) * speed
#		velocity += accelerat * delta
#		velocity = velocity.clamped(speed)
#		rotation = velocity.angle()
#		if position.distance_to(target) > dead_zone:
#			position += velocity * delta
#		print(velocity.length())
#
#func SetPlayer(cred: int, mining: int, cargoxt: int, cargoh: int, pos: Vector2) -> void:
#	player_credits = cred
#
#	match mining:
#		1:
#			player_mining_laser = MINING_LASER.MINING_LASER_I
#		2:
#			player_mining_laser = MINING_LASER.MINING_LASER_II
#		3:
#			player_mining_laser = MINING_LASER.MINING_LASER_III
#		4:
#			player_mining_laser = MINING_LASER.MINING_LASER_IV
#		5:
#			player_mining_laser = MINING_LASER.MINING_LASER_V
#
#	match cargoxt:
#		0:
#			player_cargo_extender = CARGO_EXTENDER.NO_CARGO_EXTENDER
#		1:
#			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_I
#		2:
#			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_II
#		3:
#			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_III
#		4:
#			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_IV
#		5:
#			player_cargo_extender = CARGO_EXTENDER.CARGO_EXTENDER_V
#
#	player_cargo_hold = cargoh
#	position = pos
