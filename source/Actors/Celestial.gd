extends Area2D

## A Celestial is a node that shows up in the game world. 
##
## It represent an actual object, like a station or an asteroid. Extends Area2D.
## It is something that will show up on the Overview.
## A celestial is a baseclass, while it can exists on its own, there are more specialized objects deriving from it.
class_name Celestial

# Member variables
# ----------------

## This is the name of this celestial as it will show in the Overview.
export var overview_name: String = ""

## This is the icon of this celestial as it will show in the Overview.
export var overview_icon: Resource = load("res://icon.png")

## This is the icon of this celestial as it will show in the Overview Selection box.
export var overview_selection_icon: Resource = load("res://icon.png")

## Is this celestial warpable to? Default: false
export var warpable_to: bool = false

## Is this celestial movable to? Default: true
export var movable_to: bool = true

## Is this celestial minable? Default: false
export var minable: bool = false

## Is this celestial dockable? Default: false
export var dockable: bool = false

## Should this element appear on the overview? Default: true
export var overview_visibile: bool = true

## The offset distance, to avoid the player to get inside of the station when moving/warping
export var offset_distance: int = 120

## Global position offset. This get's added to the base global_position.
## If you want it to coincide with global_position, leave it to 0
export var offset_global_position: float = 0

## Kind of Celestial
enum Type {
	CELESTIAL		= 0,  ## Undifferentiated Celestial
	STATION			= 1,  ## Station, dockable and warpable.
	ASTEROID_BELT	= 2,  ## Asteroid belt, warpable (space position)
	STAR			= 3,  ## System star, warpable (space position)
	ASTEROID		= 4,  ## Minable asteroid, movable to
	ANOMALY			= 5,  ## Damaging anomaly, no action
}

## This celestial's type (default CELESTIAL)
export (Type) var CelestialType = Type.CELESTIAL

## Constructor
# ------------
func _ready():
#	# Check if the offset_global_position has been set
#	if offset_global_position != 0:
#		# There's an offset, change it so it matches the global_position PLUS this offset
#		# This is needed to properly "MOVE TO" on a celestial
#		offset_global_position = global_position + offset_global_position
#	else:
#		# There's no offset, so it should match the actual global position
#		offset_global_position = global_position
		
	## Add this note to the group "celestial"
	add_to_group("celestials")
		
	## TODO: You could calculate a random offset (if a bool is true) so that it's not always the same for all asteroids
	## TODO: what about a bigger circle to be used as "ok that's near enough!" to stop the ship instead?
	
