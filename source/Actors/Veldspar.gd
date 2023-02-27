extends Asteroid

## A Veldspar astroid is a node that shows up in the game world. 
##
## It represent a veldspar asteroid object, extends Asteroid.
## Since there only is Veldspar currently, it's kind of redundant, but it's here for future proofing.
class_name Veldspar

onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

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
	
	if start_ore_amount > 5000:
		scale = Vector2(1, 1)
		#collision_shape_2d.shape.radius = collision_shape_2d.shape.radius * 5		
	elif start_ore_amount > 2500:
		scale = Vector2(0.5, 0.5)
		#collision_shape_2d.shape.radius = collision_shape_2d.shape.radius * 2.5
	elif start_ore_amount > 1000:
		scale = Vector2(0.25, 0.25)		
	else:
		scale = Vector2(0.1, 0.1)
		#collision_shape_2d.shape.radius = collision_shape_2d.shape.radius / 2
	
func selected(selected: bool) -> void:
	#Toggle selection circle visibility
	$SelectionCircle.visible = selected
	
	#Set the selected variable (from Asteroid)
	self.selected = selected
		
func deselect_asteroids() -> void:
	var celestials = get_tree().get_nodes_in_group("celestials")
	
	for celestial in celestials:
		if celestial.minable and celestial.is_selected():
			celestial.selected(false)
