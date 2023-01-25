extends Node

# References to the nodes in our scene
onready var _anim_player := $AnimationPlayer
onready var _exodus := $Exodus
onready var _incursion := $Incursion
onready var _crucible := $Crucible
export(String, "Exodus", "Incursion", "Crucible") var starting_theme


var fading_out_for_good: bool = false

func _ready() -> void:
	# at the beginnig, play...
	match starting_theme:
		"Exodus":
			$Exodus.play()	
		"Incursion":
			$Incursion.play()
		"Crucible":
			$Crucible.play()

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
			
func fade_out() -> void:
	#this fades current music off quickly as we need to change scene
	fading_out_for_good = true
	
	if _incursion.is_playing():
		_anim_player.play("FadeOutIncursion")
	elif _exodus.is_playing():		
		_anim_player.play("FadeOutExodus")
	elif _crucible.is_playing():		
		_anim_player.play("FadeOutCrucible")

func _on_Exodus_finished():
	if fading_out_for_good != true:
		crossfade("incursion")
		print("Play incursion next...")

func _on_Incursion_finished():
	if fading_out_for_good != true:
		crossfade("crucible")
		print("Play crucible next...")

func _on_Crucible_finished():
	if fading_out_for_good != true:
		crossfade("exodus")
		print("Play exodus next...")
