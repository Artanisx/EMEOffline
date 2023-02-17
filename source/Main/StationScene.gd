extends ColorRect
onready var scene_transition: ColorRect = $SceneTransition
onready var credits_and_cargo_label: Label = $RightStationContainer/RightStationPanel/VBoxContainer/CreditsAndCargoLabel
onready var refining_popup: Popup = $RefiningPopup

## The animation speed
export var animation_speed: float = 0.01

## The mining fee
export var refining_fee: int = 5
export var refining_threshold: int = 100

# Player variables
var creds: int = 0
var cargo: int = 0
var laser: int = 0
var cargoext: int = 0
var station_tritanium: int = 0

# Animation
var timer = 0

# DEBUG MODE
var debug_mode = true

func _ready() -> void:
	creds = Globals.get_account_credits()
	cargo = Globals.get_account_cargohold()
	laser = Globals.get_account_mininglaser()
	cargoext = Globals.get_account_cargoextender()
	
	update_creds_cargo()
	
func update_creds_cargo() -> void:	
	credits_and_cargo_label.text = "Credits: " + str(creds) + " ASK\nCargo Hold: " + str(cargo) + " m3 Veldspar\nTritanium: " + str(station_tritanium) + " m3"

func _process(delta: float) -> void:
	timer = timer + animation_speed
	
	self.material.set_shader_param("iTime", timer)		
	
func _unhandled_input(event: InputEvent) -> void:	
	# Undock by clicking escape
	if Input.is_action_just_released("ui_cancel"):
		undock()
		
	if debug_mode:
		# F1: MORE CARGO
		if Input.is_key_pressed(16777244):
			cargo = cargo + 100
		
		# F2: MORE CREDS
		if Input.is_key_pressed(16777245):
			creds = creds + 1000
	
func undock() -> void:
	# Undock for now simply loads back the game world scene
	scene_transition.transition_to("res://source/Main/GameWorld.tscn")

func _on_UndockButton_pressed() -> void:
	undock()

func _on_RefineButton_pressed() -> void:	
	refining_popup.set_refine(cargo, refining_fee, refining_threshold)
	refining_popup.popup_centered()

func _on_RefiningPopup_refining_complete(final_tritanium) -> void:
	# we have finished a refining process, update tritanium
	station_tritanium = final_tritanium
	
	#Udpate ui
	update_creds_cargo()
