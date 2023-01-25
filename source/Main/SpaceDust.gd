extends Particles2D

export(String, "Left", "Right", "Up", "Down") var space_dust_direction

func _ready():
	match space_dust_direction:
		"Left":
			position.x = 640
			rotation_degrees = 0
		"Right":
			position.x = -640
			rotation_degrees = 180
			
func direction(direction: String) -> void:
	match direction:
		"Left":
			position.x = 640
			rotation_degrees = 0
		"Right":
			position.x = -640
			rotation_degrees = 180
