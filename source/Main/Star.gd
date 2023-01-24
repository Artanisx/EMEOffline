extends Light2D

onready var _animation_player := $AnimationPlayer

export(String, "PulsatingBlueStar", "PulsatingRedStar") var star_color

func _ready():
	_animation_player.play(star_color)
