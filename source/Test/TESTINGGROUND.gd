extends Node2D
onready var laser_beam_2d: RayCast2D = $Testplayer/LaserBeam2D
onready var veldspar_asteroid: Area2D = $VeldsparAsteroid

func _ready():	
	laser_beam_2d.beam_target = veldspar_asteroid.global_position
	
func _unhandled_input(event: InputEvent) -> void:
	 # Turn on casting if Enter or Space is pressed.
	if event.is_action_pressed("ui_accept"):
		laser_beam_2d.set_is_casting(true)

	# Stop casting the beam upon releasing the key.
	elif event.is_action_released("ui_accept"):
		laser_beam_2d.set_is_casting(false)

