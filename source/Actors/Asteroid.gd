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
export var start_ore_amount: int = 5000

## How quickly this asteroid should rotate
export var rotation_speed = 1

## This should be an AudioStreamPlayer
onready var _audio_aura_depleted: AudioStreamPlayer = $AURA_Depleted

## This is the quantity of Ore it contains
var ore_amount: int = 0

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
		_audio_aura_depleted.connect("finished", self, "on_depleted_finished")	
		add_child(_audio_aura_depleted)		
		
	# Connect the finished signal
	_audio_aura_depleted.connect("finished", self, "on_depleted_finished")		
	
## Override _process to slowly rotate the asteroid
func _process(delta):
	rotation += rotation_speed * delta

## This function should be called at the end of a mining cycle to mine it
## It returns an amount and the asteroid kind (Veldspar currently)
func get_mined(mined_amount: int) -> Array:
	if (ore_amount > mined_amount):
		# There's enough ore for this cycle
		ore_amount -= mined_amount
		
		# Return this mined amount so it can be added to the cargo hold
		return [mined_amount, AsteroidKind]	
	else:
		# There's not enough ore for this cycle
		emit_signal("asteroid_depleted")
		
		# Play "The asteroid is Depleted"
		_audio_aura_depleted.play()
		
		## TO DO: START DESTROY ASTEROID ANIMATION so, when audio is done and the asteroid is queued_free there is not abrupt vanish
		
		# For now let's instantly hide it at least
		hide()
		return [0, Kind.EMPTY]
		
func on_depleted_finished() -> void:			
	queue_free()	
