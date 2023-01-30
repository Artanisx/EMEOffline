extends Asteroid

## A Veldspar astroid is a node that shows up in the game world. 
##
## It represent a veldspar asteroid object, extends Asteroid.
## Since there only is Veldspar currently, it's kind of redundant, but it's here for future proofing.
class_name Veldspar

## Constructor - Overridden
# -------------------------
func _init():	
	# This is a Veldspar asteroid
	AsteroidKind = Kind.VELDSPAR	
	overview_name = "Asteroid (Veldspar)" 
	overview_icon = load("res://assets/art/ui/veldspar_icon_overview.png")
	overview_selection_icon = load("res://assets/art/ui/veldspar_icon.png")
	
func _ready() -> void:
	# Set the start ore amount. It must be done here or any editor udpated value would be ignored
	ore_amount = start_ore_amount
