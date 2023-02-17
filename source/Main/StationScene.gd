extends ColorRect

## The animation speed
export var animation_speed: float = 0.01

var timer = 0

func _process(delta: float) -> void:
	timer = timer + animation_speed
	
	self.material.set_shader_param("iTime", timer)		
