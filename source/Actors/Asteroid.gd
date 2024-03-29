extends Celestial

## An Asteroid is a node that shows up in the game world. 
##
## It represent an asteroid object, extends Celestial.
class_name Asteroid

# Signals
signal asteroid_depleted

# Member variables
# ----------------

## The starting amount of ore
export var start_ore_amount: float = 5000

## How quickly this asteroid should rotate
var rotation_speed = 1
export var min_speed = -2.5
export var max_speed = 2.5

## This should be an AudioStreamPlayer
onready var _audio_aura_depleted: AudioStreamPlayer = $AURA_Depleted

## This is the quantity of Ore it contains
var ore_amount: float = 0

## This is the tween to be used to scale down the asteroid while its being mined
var scale_tween : Tween = Tween.new()

## Kind of Asteroid [CURRENTLY UNUSED]
enum Kind {
	EMPTY				= 0,  ## EMPTY ASTEROID
	VELDSPAR			= 1,  ## Veldspar Asteroid
	KERNITE				= 2,  ## Kernite Asteroid [UNUSED]
	SCORDITE			= 3,  ## Scordite Asteroid [UNUSED]
}

## This asteroid kind (default VELDSPAR)
export (Kind) var AsteroidKind = Kind.VELDSPAR

## Density of Asteroid [CURRENTLY UNUSED]
enum Density {
	NORMAL			= 0,  ## Normal asteroid
	CONCENTRATED	= 1,  ## Yield incrased by 5%
	DENSE			= 2,  ## Yied increased by 10%
}

## This asteroid density (default NORMAL) [CURRENTLY UNUSED]
export (Density) var AsteroidDensity = Density.NORMAL

var selected: bool = false
var rng = RandomNumberGenerator.new()

## Constructor
# ------------
func _init():
	# This is an asteroid so set it's celestial type accordingly
	CelestialType = Type.ASTEROID
	
	# Set the celestial variables for a minable Asteroid
	warpable_to = false
	movable_to = true
	minable = true
	dockable = false
	overview_visibile = true

func _ready():
	# Check if the AudioStream has been set
	if (_audio_aura_depleted == null):
		printerr("DEV - You forgot to add the AudioStream to the asteroid. I'll add it myself.")
		_audio_aura_depleted = AudioStreamPlayer.new()
		_audio_aura_depleted.stream = load("res://assets/audio/aura/asteroid_depleted.mp3")
		var _err = _audio_aura_depleted.connect("finished", self, "on_depleted_finished")	
		add_child(_audio_aura_depleted)		
		
	# Connect the finished signal
	var _err2 = _audio_aura_depleted.connect("finished", self, "on_depleted_finished")	
	
	# Add the tween and its signal
	add_child(scale_tween)	
	#scale_tween.connect("tween_all_completed", self, "_on_scale_tween_completed")	 #might not be needed
	
	# Set random rotation (based upon ore mount and export speeds)
	rng.randomize()
		
	if start_ore_amount > 4000:
		max_speed = max_speed / 3
		min_speed = min_speed / 3
	elif start_ore_amount > 2000:
		max_speed = max_speed / 2
		min_speed = min_speed / 2
	elif start_ore_amount > 1000:
		max_speed = max_speed / 1.5	
		min_speed = min_speed / 1.5	
	
	var my_random_number = rng.randf_range(min_speed, max_speed)
	rotation_speed = my_random_number
	
## Override _process to slowly rotate the asteroid
func _process(delta):
	rotation += rotation_speed * delta

## This function should be called at the end of a mining cycle to mine it
## It returns an amount and the asteroid kind (Veldspar currently)
func get_mined(mined_amount: int) -> Array:
	if (ore_amount > mined_amount):
		# There's enough ore for this cycle
		ore_amount -= mined_amount
		
		var percentage_left: float = float(100 / (start_ore_amount / ore_amount))
		
#		var scale_to = 0
#
#		if percentage_left > 10:
#			scale_to = 0.9
#		else:
#			scale_to = 0.1

		var scale_to = percentage_left / 100
		
		var vec_scale_to = Vector2(scale.x * scale_to, scale.y * scale_to)
		
		
		var _err = scale_tween.interpolate_property(self, "scale", scale, vec_scale_to, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		var _err2 = scale_tween.start()				
		
		# Return this mined amount so it can be added to the cargo hold
		return [mined_amount, AsteroidKind]	
	else:
		# There's not enough ore for this cycle
		emit_signal("asteroid_depleted")
		
		# For now let's instantly hide it at least
		hide()
		
		# Play "The asteroid is Depleted"
		_audio_aura_depleted.play()			
		
		return [0, Kind.EMPTY]
		
func on_depleted_finished() -> void:			
	queue_free()	
	
func is_selected() -> bool:
	return selected
