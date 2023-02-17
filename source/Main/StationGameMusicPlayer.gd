extends Node

# References to the nodes in our scene
onready var _anim_player := $AnimationPlayer
onready var _miner_stories := $MinerStories
export(String, "MinerStories") var starting_theme

func _ready() -> void:
	# at the beginnig, play...
	match starting_theme:
		"MinerStories":
			$MinerStories.play()
			# Add a fadein effect with animationplayer
