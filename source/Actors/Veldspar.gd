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
	
func selected(selected: bool) -> void:
	#Toggle selection circle visibility
	$SelectionCircle.visible = selected
	
	#Set the selected variable (from Asteroid)
	self.selected = selected

func _on_VeldsparAsteroid_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
#	if Input.is_action_pressed("left_click"):
#		deselect_asteroids()			
#		selected(true)		
	# clicking on empty space deselects everything, so for the moment let's not allow selection by mouse click
	pass
		
func deselect_asteroids() -> void:
	var celestials = get_tree().get_nodes_in_group("celestials")
	
	for celestial in celestials:
		if celestial.minable and celestial.is_selected():
			celestial.selected(false)
