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
	overview_icon = load("res://assets/art/ui/veldspar_icon.png")