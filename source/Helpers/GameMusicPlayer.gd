extends Node

# References to the nodes in our scene
onready var _anim_player := $AnimationPlayer
onready var _below_the_asteroids := $BelowTheAsteroids
export(String, "BelowTheAsteroids") var starting_theme

func _ready() -> void:
	# at the beginnig, play...
	match starting_theme:
		"BelowTheAsteroids":
			$BelowTheAsteroids.play()
			# Add a fadein effect with animationplayer
