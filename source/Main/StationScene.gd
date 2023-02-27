extends ColorRect
onready var scene_transition: ColorRect = $SceneTransition
onready var credits_and_cargo_label: Label = $RightStationContainer/RightStationPanel/VBoxContainer/CreditsAndCargoLabel
onready var refining_popup: Popup = $RefiningPopup
onready var message: Label = $MIDHUD/MESSAGE
onready var animation_player: AnimationPlayer = $MIDHUD/AnimationPlayer
onready var sell_popup: PopupDialog = $SellPopup
onready var market_popup: PopupDialog = $Market
onready var right_arrow: TextureRect = $RightArrow


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
export var tutorial_speed: float = 1.0

# Animation
var timer = 0

# DEBUG MODE
var debug_mode = true
var FORCE_TUTORIAL: bool = false

signal tutorial_refine_button_pressed
signal tutorial_refine_completed
signal tutorial_sale_button_pressed
signal tutorial_sale_completed

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
	
	if (FORCE_TUTORIAL):
		printerr("FORCE TUTORIAL IS ON!")

func start_tutorial() -> void:
	# Check if this is the first time the player is entering the universe and he's doing the tutorial
	if (station_tritanium == 1 or FORCE_TUTORIAL):
		# It is not possible to obtain a single unit of tritanium through normal play
		# This means it's the first login and currently doing the tuttorial
		is_first_login = true
		is_tutorial_running = true
		print("Station tutorial time!")
		
		#TUTORIAL START
		show_mid_message("This is the station.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")		
		show_mid_message("Here you can refine your ores into minerals.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")		
		show_mid_message("Minerals can be sold for credits (AKA).")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")		
		show_mid_message("With credits you can buy upgrades.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			show_mid_message("Tutorial aborted.")
			return
			
		show_arrow(1)
		show_mid_message("This is the REFINE button.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		show_mid_message("Clicking on this will allow you to refine minerals.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		show_mid_message("Click on it now.")
		
		yield(self, "tutorial_refine_button_pressed")
		cargo = 100
		update_creds_cargo()
		
		show_mid_message("Good job.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		show_mid_message("You have been given 100 Veldspar for this tutorial.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		show_arrow(1)
		show_mid_message("Click REFINE to refine 100 veldsar into 20 Tritanium.")
		
		yield(self, "tutorial_refine_completed")
		show_mid_message("Good job.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			show_mid_message("Tutorial aborted.")
			return
			
		show_arrow(2)
		show_mid_message("This is the SELL button.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		show_mid_message("This will allow you to sell minerals for credits.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		show_mid_message("Click on it now.")
		
		yield(self, "tutorial_sale_button_pressed")
		
		show_mid_message("Good job.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		show_mid_message("Now sell your minerals to obtain credits (AKA)")
		
		yield(self, "tutorial_sale_completed")
		
		show_mid_message("Good job.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			show_mid_message("Tutorial aborted.")
			return
			
		show_arrow(3)
		show_mid_message("This is the MINING LASER market button.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("It will allow you to buy mining upgrades.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("Upgrades increase mining yield, ")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("decrease mining cycle, ")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("and increase range.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			show_mid_message("Tutorial aborted.")
			return
			
		show_arrow(4)
		show_mid_message("This is the CARGO EXTENDER market button.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("It will allow you to buy cargo hold upgrades.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("Each upgrade allow your cargo hold to store more.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			show_mid_message("Tutorial aborted.")
			return
		
		show_arrow(5)
		show_mid_message("This is the UNDOCK button.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("It will allow you to exit the station.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("You can do so in order to go back to the world.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			show_mid_message("Tutorial aborted.")
			return
		
		show_arrow(6)
		show_mid_message("Lastly, this is your WALLET info.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("You can see your cargo hold contents, ")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("Your credits and your Tritanium.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		show_mid_message("Tritanium will stay stored in the station vault.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		show_mid_message("Tutorial is now complete. Have fun!")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		#Make the arrow invisible now
		show_arrow(7)
		
		#Set account tritanium to 2 so the station tutorial  won't be shown again
		Globals.set_account_station_tritanium(2)
				
		# Tutorial is over
		is_tutorial_running = false
		return
			
	else:
		is_first_login = false
		is_tutorial_running = false
		print("No tutorial time!")
		return

func show_arrow(which_arrow: int) -> void:
	match which_arrow:
		1:	
			# REFINE BUTTON
			right_arrow.rect_position = Vector2(950,305)
			right_arrow.rect_rotation = 0
			right_arrow.visible = true
		2:
			# SELL BUTTON
			right_arrow.rect_position = Vector2(1215,353)
			right_arrow.rect_rotation = 180
			right_arrow.visible = true
		3:
			# MINING LASER BUTTON
			right_arrow.rect_position = Vector2(950,380)
			right_arrow.rect_rotation = 0
			right_arrow.visible = true	
		4:
			# EXPANDED CARGO LASER BUTTON
			right_arrow.rect_position = Vector2(1093,499)
			right_arrow.rect_rotation = -90
			right_arrow.visible = true	
		5:
			# UNDOCK
			right_arrow.rect_position = Vector2(1280,423)
			right_arrow.rect_rotation = 180
			right_arrow.visible = true	
		6: 
			# WALLET INFO
			right_arrow.rect_position = Vector2(1115,614)
			right_arrow.rect_rotation = -90
			right_arrow.visible = true	
		_:
			right_arrow.visible = false
			
func abort_tutorial() -> void:	
	is_tutorial_running = false
	
	#Set station tritanium to 2 will make sure this tutorial won't be offered again
	Globals.set_account_station_tritanium(2)
	
	#Make the arrow invisible now
	

func update_creds_cargo() -> void:	
	credits_and_cargo_label.text = "Credits: " + str(creds) + " ASK\nCargo Hold: " + str(cargo) + " m3 Veldspar\nTritanium: " + str(station_tritanium) + " m3"

func _process(_delta: float) -> void:
	timer = timer + animation_speed
	
	self.material.set_shader_param("iTime", timer)		
	
func _unhandled_input(_event: InputEvent) -> void:			
	if (is_tutorial_running):
		# The only unhandled input we accept when the tutorial is running is escape to skip it		
		if Input.is_action_just_released("ui_cancel"):
			abort_tutorial()
	else:		
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
	if (is_tutorial_running):
		emit_signal("tutorial_refine_button_pressed")
	refining_popup.set_refine(cargo, refining_fee, refining_threshold)
	refining_popup.popup_centered()	

func _on_RefiningPopup_refining_complete(final_tritanium, final_ore) -> void:
	if (is_tutorial_running):
		emit_signal("tutorial_refine_completed")
		
	# we have finished a refining process, update tritanium
	station_tritanium = station_tritanium + final_tritanium
	cargo = final_ore
	
	#Udpate ui
	update_creds_cargo()
	
	show_mid_message("Refining complete!")
	
	
func _on_RefiningPopup_send_message(fun_message) -> void:
	show_mid_message(fun_message)

func _on_SellButton_pressed() -> void:	
	if (is_tutorial_running):
		emit_signal("tutorial_sale_button_pressed")
		
	sell_popup.set_sale(station_tritanium, sale_fee, sale_threshold, sale_ASK_threshold)
	sell_popup.popup_centered()

func _on_SellPopup_sale_complete(final_sale, final_trit) -> void:
	if (is_tutorial_running):
		emit_signal("tutorial_sale_completed")

	# we have finished selling tritanium, update values
	station_tritanium = final_trit
	creds = creds + final_sale
	
	# Save data to globals  (but not to file yet) so one could sell again and get proper results
	Globals.save_to_Globals(creds, laser, cargoext, cargo, pos, station_tritanium)
	
	#Udpate ui
	update_creds_cargo()
	
	show_mid_message("Sale complete!")

func _on_SellPopup_send_message(fun_message) -> void:
	show_mid_message(fun_message)

func _on_BuyMiningLaserButton_pressed() -> void:
	market_popup.set_market("MiningLaser", creds)	
	market_popup.popup_centered()

func _on_Market_send_message(fun_message) -> void:
	show_mid_message(fun_message)

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
