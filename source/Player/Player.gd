extends Area2D

export(String, "Direct", "RTS") var movement_mode
export var rotation_speed: float = PI
export var speed: float = 100
export var dead_zone: int = 5

onready var target = position
onready var _space_dust = $Camera2D/SpaceDust			

# Player velocity vector
var velocity = Vector2()

# Player Stats


# DEBUGGING
const max_zoom_out = 10

func _physics_process(delta):
	get_input()
	
	_space_dust.global_position = global_position
	
	if (movement_mode == "Direct"):		
		position += velocity * delta
	elif (movement_mode == "RTS"):
		velocity = position.direction_to(target) * speed
		
		## SMOOTH LOOKAT
		# vector from the ship to the target
		var v = target - self.global_position
		
		# get the angle of that vector
		var angle = v.angle()
		var r = global_rotation
		
		# ger toation allowed this frame
		var angle_delta = rotation_speed * delta
		
		#get complete rotation to target
		angle = lerp_angle(r, angle, 1.0)
		
		# limit that rotaiton to what is allowed this frame
		angle = clamp(angle, r - angle_delta, r + angle_delta)
		
		# set ship rotation
		global_rotation = angle		
				
		# Move only if the target is at least dead_zone units away and after the rotation to look at has finished		
		if position.distance_to(target) > dead_zone and rotation == angle:
			position += velocity * delta	
			
		if velocity.x > 0:
			_space_dust.direction("Left")
		elif velocity.x < 0:
			_space_dust.direction("Right")

func get_input():
	if (movement_mode == "Direct"):
		velocity = Vector2()
		
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1	
			
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
	elif (movement_mode == "RTS"):
		if Input.is_action_just_released("left_click"):
			target = get_global_mouse_position()			
		
	if Input.is_action_just_released("zoom_out"):		
		#mouse_wheel down, zoom out
		var cur_zoom = $Camera2D.get_zoom()
		
		if cur_zoom.x < max_zoom_out:
			 #we're not too much zoomed out
			cur_zoom = Vector2(cur_zoom.x + 1, cur_zoom.y + 1)
			$Camera2D.set_zoom(cur_zoom)
			
	if Input.is_action_just_released("zoom_in"):		
		#mouse_wheel up, zoom in
		var cur_zoom = $Camera2D.get_zoom()		
		
		if cur_zoom.x > 1:						
			 #we're not too much zoomed in
			cur_zoom = Vector2(cur_zoom.x - 1, cur_zoom.y - 1)
			$Camera2D.set_zoom(cur_zoom)			
	
