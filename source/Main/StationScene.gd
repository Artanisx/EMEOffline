extends ColorRect
onready var scene_transition: ColorRect = $SceneTransition

## The animation speed
export var animation_speed: float = 0.01

var timer = 0

func _process(delta: float) -> void:
	timer = timer + animation_speed
	
	self.material.set_shader_param("iTime", timer)		
	
func _unhandled_input(event: InputEvent) -> void:	
	# Undock by clicking escape
	if Input.is_action_just_released("ui_cancel"):
		undock()
	
func undock() -> void:
	# Undock for now simply loads back the game world scene
	scene_transition.transition_to("res://source/Main/GameWorld.tscn")
