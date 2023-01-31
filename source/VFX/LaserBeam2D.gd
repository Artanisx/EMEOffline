class_name LaserBeam2D
extends RayCast2D

export var cast_speed : float = 7000.0
export var max_length : float = 1400
export var growth_time := 0.1

var is_casting := false setget set_is_casting

onready var fill := $FillLine2D
onready var tween := $Tween
onready var casting_particles := $CastingParticles2D
onready var collision_particles := $CollisionParticles2D
onready var beam_particles := $BeamParticles2D

onready var line_width: float = fill.width

var beam_target = Vector2.RIGHT
var direction = Vector2.RIGHT


func _ready() -> void:
	set_physics_process(false)
	fill.points[1] = Vector2.ZERO	

func _physics_process(delta: float) -> void:
	#cast_to = (cast_to + beam_target * cast_speed * delta).clamped(max_length)	
	direction = (beam_target - self.global_position).normalized()	
	cast_to = cast_to + direction * cast_speed * delta 
	cast_beam()	
	
func cast_beam() -> void:
	var cast_point := cast_to
	
	force_raycast_update()
	
	collision_particles.emitting = is_colliding()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		collision_particles.global_rotation = get_collision_normal().angle()
		collision_particles.position = cast_point
		
	fill.points[1] = cast_point
	beam_particles.position = cast_point * 0.5
	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5
	
func appear() -> void:
	if tween.is_active():
		tween.stop_all()
		
	tween.interpolate_property(fill, "width", 0, line_width, growth_time * 2)
	tween.start()
		
func disappear() -> void:
	if tween.is_active():
		tween.stop_all()
	
	tween.interpolate_property(fill, "width", fill.width, 0, growth_time)
	tween.start()

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	if is_casting:		
		cast_to = Vector2.ZERO
		fill.points[1] = cast_to
		appear()
	else:
		disappear()
		
	set_physics_process(is_casting)	
	casting_particles.emitting = is_casting	
	beam_particles.emitting = is_casting
	collision_particles.emitting = is_casting
		
