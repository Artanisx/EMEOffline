extends Celestial

## A Station is a node that shows up in the game world. 
##
## It represent a station object, extends Celestial.
class_name Station

# Signals
#signal signal_name

# Member variables
# ----------------
var selected: bool = false

## Constructor
# ------------
func _init():
	# This is an asteroid so set it's celestial type accordingly
	CelestialType = Type.STATION
	
	# Set the celestial variables for a minable Asteroid
	warpable_to = true
	movable_to = true
	minable = false
	dockable = true
	overview_visibile = true
		
	overview_name = "DC Mining Refinery" 
	overview_icon = load("res://assets/art/ui/station_icon_overview.png")
	overview_selection_icon = load("res://assets/art/ui/station_icon.png")	
	
func selected(selected: bool) -> void:
	#Toggle selection circle visibility
	$SelectionCircle.visible = selected
	
	#Set the selected variable (from Asteroid)
	self.selected = selected
	
func is_selected() -> bool:
	return selected
