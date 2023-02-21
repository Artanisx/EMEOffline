extends ColorRect
onready var scene_transition: ColorRect = $SceneTransition
onready var credits_and_cargo_label: Label = $RightStationContainer/RightStationPanel/VBoxContainer/CreditsAndCargoLabel
onready var refining_popup: Popup = $RefiningPopup
onready var message: Label = $MIDHUD/MESSAGE
onready var animation_player: AnimationPlayer = $MIDHUD/AnimationPlayer
onready var sell_popup: PopupDialog = $SellPopup


## The animation speed
export var animation_speed: float = 0.01

## The mining fee
export var refining_fee: int = 5
export var refining_threshold: int = 100

## The sale fee
export var sale_fee: int = 5
export var sale_threshold: int = 1 #Number of trit unit for a sale
export var sale_ASK_threshold: int = 100 #Number of ASK for each threshold sale

# Player variables
var creds: int = 0
var cargo: int = 0
var laser: int = 0
var cargoext: int = 0
var pos: Vector2 = Vector2.ZERO
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
	pos = Globals.get_account_position()
	station_tritanium = Globals.get_account_station_tritanium()
	
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
			cargo = cargo + 10
			update_creds_cargo()
			show_mid_message("You cheated!")
		
		# F2: MORE CREDS
		if Input.is_key_pressed(16777245):
			creds = creds + 1000
			update_creds_cargo()
			show_mid_message("You cheated!")
			
		# F3: MORE TRITS
		if Input.is_key_pressed(16777246):
			station_tritanium = station_tritanium + 10
			update_creds_cargo()
			show_mid_message("You cheated!")

func show_mid_message(message_to_show: String) -> void:
	message.text = message_to_show	
	animation_player.play("FadeIn")
	
func fade_out_message() -> void:
	animation_player.play("FadeOut")
	
func undock() -> void:
	#Save file before undocking
	Globals.save_to_Globals(creds, laser, cargoext, cargo, pos, station_tritanium)
	
	if (Globals.save()):
		# All good, undock now!
		scene_transition.transition_to("res://source/Main/GameWorld.tscn")
	else:
		# save() failed or didn't complete!		
		printerr("Failed to save, aborting dock sequence.")
		show_mid_message("Unable to undock!")
		return

func _on_UndockButton_pressed() -> void:
	undock()

func _on_RefineButton_pressed() -> void:	
	refining_popup.set_refine(cargo, refining_fee, refining_threshold)
	refining_popup.popup_centered()

func _on_RefiningPopup_refining_complete(final_tritanium, final_ore) -> void:
	# we have finished a refining process, update tritanium
	station_tritanium = station_tritanium + final_tritanium
	cargo = final_ore
	
	#Udpate ui
	update_creds_cargo()
	
	show_mid_message("Refining complete!")
	
func _on_RefiningPopup_send_message(message) -> void:
	show_mid_message(message)

func _on_SellButton_pressed() -> void:	
	sell_popup.set_sale(station_tritanium, sale_fee, sale_threshold, sale_ASK_threshold)
	sell_popup.popup_centered()

func _on_SellPopup_sale_complete(final_sale, final_trit) -> void:
	# we have finished selling tritanium, update values
	station_tritanium = final_trit
	creds = creds + final_sale
	
	#Udpate ui
	update_creds_cargo()
	
	show_mid_message("Sale complete!")
