extends ColorRect
onready var scene_transition: ColorRect = $SceneTransition
onready var credits_and_cargo_label: Label = $RightStationContainer/RightStationPanel/VBoxContainer/CreditsAndCargoLabel
onready var refining_popup: Popup = $RefiningPopup
onready var message: Label = $MIDHUD/MESSAGE
onready var animation_player: AnimationPlayer = $MIDHUD/AnimationPlayer
onready var sell_popup: PopupDialog = $SellPopup
onready var market_popup: PopupDialog = $Market


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

var is_tutorial_running: bool = false
var is_first_login: bool = false

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
	
	show_mid_message("Your ship has been repaired!")	
	
	# Show the cursor again in case it was hidden by death
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Tutorial
	start_tutorial()

func start_tutorial() -> void:
	# Check if this is the first time the player is entering the universe and he's doing the tutorial
	if (station_tritanium == 1):
		# It is not possible to obtain a single unit of tritanium through normal play
		# This means it's the first login and currently doing the tuttorial
		is_first_login = true
		is_tutorial_running = true
		print("Station tutorial time!")
	else:
		is_first_login = false
		is_tutorial_running = false
		print("No tutorial time!")
		return

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
			creds = creds + 10000
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
	
	# Save data to globals  (but not to file yet) so one could sell again and get proper results
	Globals.save_to_Globals(creds, laser, cargoext, cargo, pos, station_tritanium)
	
	#Udpate ui
	update_creds_cargo()
	
	show_mid_message("Sale complete!")

func _on_SellPopup_send_message(message) -> void:
	show_mid_message(message)

func _on_BuyMiningLaserButton_pressed() -> void:
	market_popup.set_market("MiningLaser", creds)	
	market_popup.popup_centered()

func _on_Market_send_message(message) -> void:
	show_mid_message(message)

func _on_Market_mining_laser_upgrade_complete(current_mining_laser, current_credits) -> void:
	creds = current_credits
	laser = current_mining_laser
	
	# Save data to globals  (but not to file yet) so one could buy again and get proper results
	Globals.save_to_Globals(creds, laser, cargoext, cargo, pos, station_tritanium)
	
	#Update ui
	update_creds_cargo()
	
	show_mid_message("Upgrade complete!")

func _on_BuyExpandedHoldButton_pressed() -> void:
	market_popup.set_market("CargoExtender", creds)	
	market_popup.popup_centered()	


func _on_Market_cargo_extender_upgrade_complete(current_cargo_expander, current_credits) -> void:
	creds = current_credits
	cargoext = current_cargo_expander
	
	# Save data to globals  (but not to file yet) so one could buy again and get proper results
	Globals.save_to_Globals(creds, laser, cargoext, cargo, pos, station_tritanium)
	
	#Update ui
	update_creds_cargo()
	
	show_mid_message("Upgrade complete!")
