extends Area2D

var target_pos: Vector2 = Vector2.ZERO
var tween : Tween = Tween.new()
var duration = 5
var speed = 100

func _ready() -> void:
	add_child(tween)	

func _input(event) -> void:
	if Input.is_action_just_released("left_click"):
		target_pos = get_global_mouse_position()
		move(target_pos)
	
func move(target_pos: Vector2) -> void:	
	# stop current movement
	tween.remove_all()
	
	# Calculate the duration the total movement should take
	# The duration should be distance / velocity
	var distance_vector = global_position - target_pos
	var distance = distance_vector.length()	
	duration = distance / speed
	
	print("Distance Vector: " + str(distance_vector) + "Distance: " + str(distance) + "Duration: " + str(duration))
	
	tween.interpolate_property(self, "position", global_position, target_pos, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()	
	# PROBLEMA: non riesco a definire la speed instantanea. ma magari vediamo di implementare la rotaziojne per prima cosa e po isi vede

func _process(delta: float) -> void:
		var cur_speed = (tween.tell())
		print(str(cur_speed))

