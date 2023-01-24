extends Node

# References to the nodes in our scene
onready var _anim_player := $AnimationPlayer
onready var _exodus := $Exodus
onready var _incursion := $Incursion
onready var _crucible := $Crucible

func _ready() -> void:
	# at the beginnig, play Exodus
	$Exodus.play()	

# crossfades to a new audio stream
func crossfade(next_theme: String) -> void:	
	
	match next_theme:
		"incursion":
			_incursion.play()
			_anim_player.play("FromExodustoIncursion")
		"crucible":
			_crucible.play()
			_anim_player.play("FadeFromIncursioToCrucible")
		"exodus":
			_exodus.play()
			_anim_player.play("FromCrucibleToExodus")

func _on_Exodus_finished():
	crossfade("incursion")
	print("Play incursion next...")

func _on_Incursion_finished():
	crossfade("crucible")
	print("Play crucible next...")

func _on_Crucible_finished():
	crossfade("exodus")
	print("Play exodus next...")
