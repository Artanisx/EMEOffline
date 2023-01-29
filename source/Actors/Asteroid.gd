extends Celestial

## An Asteroid is a node that shows up in the game world. 
##
## It represent an asteroid object, extends Celestial.
class_name Asteroid

# Member variables
# ----------------

## The starting amount of veldspar
export var start_veldspar_amount: int = 5000

## How quickly this asteroid should rotate
export var rotation_speed = 1

## This should be an AudioStreamPlayer
onready var _audio_aura_depleted: AudioStreamPlayer = $AURA_Depleted

## This is the quantity of Veldspar it contains
var veldspar_amount: int = start_veldspar_amount

## Kind of Asteroid [CURRENTLY UNUSED]
enum Density {
	NORMAL			= 0,  ## Normal asteroid
	CONCENTRATED	= 1,  ## Yield incrased by 5%
	DENSE			= 2,  ## Yied increased by 10%
}

## This asteroid density (default NORMAL) [CURRENTLY UNUSED]
export (Density) var AsteroidType = Density.NORMAL

## Constructor
# ------------
func _init():
	# This is an asteroid so set it's celestial type accordingly
	CelestialType = Type.ASTEROID

func _ready():
	# Check if the AudioStream has been set
	if (_audio_aura_depleted == null):
		printerr("DEV - You forgot to add the AudioStream to the asteroid.")
	
## Override _process to slowly rotate the asteroid
func _process(delta):
	rotation += rotation_speed * delta

## This function should be called at the end of a mining cycle to mine it
func get_mined(mined_amount: int) -> int:
	if (veldspar_amount > mined_amount):
		# There's enough veldspar for this cycle
		veldspar_amount -= mined_amount
		
		# Return this mined amount so it can be added to the cargo hold
		return mined_amount	
	else:
		# There's not enough veldspar for this cycle
		# This asteroid should be destroyed
		## TO DO: DESTROY ASTEROID		
		# Play "The asteroid is Depleted"
		_audio_aura_depleted.play()
		return 0
