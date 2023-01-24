extends Node

# References to the nodes in our scene
onready var _anim_player := $AnimationPlayer
onready var _exodus := $Exodus
onready var _incursion := $Incursion
onready var _crucible := $Crucible

# crossfades to a new audio stream
func crossfade() -> void:
	# If both tracks are playing, we're calling the function in the middle of a fade.
	# We return early to avoid jumps in the sound.
	if _exodus.playing and _incursion.playing:
		return
		
	# The `playing` property of the stream players tells us which track is active.
	# If it's track two, we fade to track one, and vice-versa.
	if _incursion.playing:		
		_crucible.play()
		_anim_player.play("FadeFromIncursioToCrucible")
	elif _crucible.playing:		
		_exodus.play()
		_anim_player.play("FromCrucibleToExodus")
	elif _exodus.playing:		
		_incursion.play()
		_anim_player.play("FromExodustoIncursion")
		
