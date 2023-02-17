extends ColorRect
onready var scene_transition: ColorRect = $SceneTransition
onready var credits_and_cargo_label: Label = $RightStationContainer/RightStationPanel/VBoxContainer/CreditsAndCargoLabel

## The animation speed
export var animation_speed: float = 0.01

var timer = 0

func _ready() -> void:
	var creds = Globals.get_account_credits()
	var cargo = Globals.get_account_cargohold()
	
	credits_and_cargo_label.text = "Credits: " + str(creds) + " ASK\nCargo Hold: " + str(cargo) + " m3 Veldspar"

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

func _on_UndockButton_pressed() -> void:
	undock()
