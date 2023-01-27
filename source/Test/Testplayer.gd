extends Area2D

var target_pos: Vector2 = Vector2.ZERO
var rotation_tween : Tween = Tween.new()
var movement_tween : Tween = Tween.new()
var duration = 0
export var movement_speed = 500
#export var rotation_speed = 100
export var rotation_duration = 0

func _ready() -> void:
	add_child(rotation_tween)
	rotation_tween.connect("tween_all_completed", self, "_on_rotation_tween_completed")		
	add_child(movement_tween)	
	#movement_tween.connect("tween_all_completed", self, "_on_movement_tween_completed")

func _input(event) -> void:
	if Input.is_action_just_released("left_click"):
		target_pos = get_global_mouse_position()
		face(target_pos)
		#move(target_pos)
	
func face(target_pos: Vector2) -> void:		
	# stop current movement
	rotation_tween.remove_all()
	
	# stop current movement
	movement_tween.remove_all()
	
	# vector from the ship to the target
	var v = target_pos - self.global_position		
		
	# get the angle of that vector
	var angle = v.angle()	
	angle = rad2deg(angle)		
	
#	# Cacolaute the duration the total rotation should take
#	# The durationg should be fullrotation / rotation_velocity
#	var full_rotation = angle	
#	rotation_duration = abs(angle) / rotation_speed	
#
#	print("Full rotation: " + str(full_rotation) + "Rotation Duration: " + str(rotation_duration))	
	
	#rotation_tween.interpolate_property(self, "rotation_degrees", global_rotation_degrees, angle, rotation_duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)	
	rotation_tween.interpolate_property(self, "rotation_degrees", global_rotation_degrees, angle, rotation_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	rotation_tween.start()		

func move(target_pos: Vector2) -> void:	
	# stop current movement
	movement_tween.remove_all()
	
	# Calculate the duration the total movement should take
	# The duration should be distance / velocity
	var distance_vector = global_position - target_pos
	var distance = distance_vector.length()	
	duration = distance / movement_speed
	
	#print("Distance Vector: " + str(distance_vector) + "Distance: " + str(distance) + "Duration: " + str(duration))	

	movement_tween.interpolate_property(self, "position", global_position, target_pos, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	movement_tween.start()	
	# PROBLEMA: non riesco a definire la speed instantanea. ma magari vediamo di implementare la rotaziojne per prima cosa e po isi vede

func _on_rotation_tween_completed() -> void:	
	move(target_pos)
	
#func _process(delta: float) -> void:
#		var cur_speed = (tween.tell())
#		print(str(cur_speed))

