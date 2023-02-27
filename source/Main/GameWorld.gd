extends Node2D

onready var _player = $Player
onready var _2dcamera = $Player/Camera2D
onready var _space_ui = $SpaceUI
onready var _space_ui_cargohold = $SpaceUI/LowerHUD/CargoHold
onready var _space_ui_speed = $SpaceUI/LowerHUD/Speed
onready var _space_ui_speed_labelms = $SpaceUI/LowerHUD/Speed/LabelSpeedMS
onready var _space_ui_hull = $SpaceUI/LowerHUD/HullIntegrity
onready var _space_ui_action = $SpaceUI/LowerHUD/LabelAction
onready var _space_ui_target = $SpaceUI/LowerHUD/LabelActionTarget
onready var _space_ui_mining_button = $SpaceUI/LowerHUD/MiningButton
onready var _space_ui_overview_table = $SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE
onready var _space_ui_overview_selection_text = $SpaceUI/OverviewHUD/VBoxContainer/SELECTIONBOX/SELECTIONTEXT
onready var _space_ui_overview_selection_icon = $SpaceUI/OverviewHUD/VBoxContainer/SELECTIONBOX/SELECTIONICON
onready var _props = $Props
onready var laser_beam_2d: RayCast2D = $LaserBeam2D
onready var _question_box: PopupDialog = $SpaceUI/QuestionBox
onready var _transition_rect := $SceneTransition

# OVERVIEW
var overview = {}
#var celestial: Celestial = Celestial.new()

var overview_selected: bool = false
var overview_selected_index = 0
var button_clicked: bool = false
var selected_instance_id: int = 0	#when an item is selceted in the overview, this holds the instance_id of the node
var player_is_mining: bool = false
var player_is_warping: bool = false
var asteroid_being_mined: Celestial = null
var current_offset_before_warp: Vector2 = Vector2.ZERO #to save the current offset before a warp/ click ot move
var is_tutorial_running: bool = false
var is_first_login: bool = false

## Celestial over this distance will not be shown in the overview
export var overview_range: int = 5000
export var player_destruction_credit_percentage_penalty: int = 10 #10% penalty
export var tutorial_speed: float = 0.2

signal tutorial_station_selected
signal tutorial_station_dock_selected	

# DEBUGGING
const max_zoom_out = 10
var warnings_given: bool = false
var DEBUG_SPEED_MINING: bool = false

func _ready() -> void:	
	# Loads player variables
	_player.SetPlayer(Globals.get_account_credits(), Globals.get_account_mininglaser(), Globals.get_account_cargoextender(), Globals.get_account_cargohold(), Globals.get_account_position())	
	
	# Set initial space_ui
	set_space_ui()
	
	# Populate OVERVIEW dictionary as needed
	create_overview_dictionary()
	
	# Create Overview UI, adding rows as required
	create_overview_ui()
	
	# Tutorial
	start_tutorial()
	
func start_tutorial() -> void:	
	# Check if this is the first time the player is entering the universe
	if (_player.position == Vector2.ZERO and _player.player_credits == 0 and _player.player_cargo_hold == 0 and Globals.get_account_station_tritanium() == 0 ):
		# This is the first login
		is_first_login = true
		is_tutorial_running = true
		
		#TUTORIAL START
		_space_ui.show_mid_message("Welcome to EME!")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Click on an empty point in space to move.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Note you can only move when not mining.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Try it now.")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
			
		# Let's the player move for 5 seconds
		is_tutorial_running = false		
		yield(_player, "movement_completed")
		is_tutorial_running = true
		_space_ui.show_mid_message("Good job.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(1)
		_space_ui.show_mid_message("This is the overview!")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Use to to warp to distant locations.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Use it also to select asteroids to mine.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(2)
		_space_ui.show_mid_message("This is the selection screen.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Use these buttons to take action on selected items.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(3)
		_space_ui.show_mid_message("This will move the ship towards the celestial.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("It's available only if the celestial is close.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(4)
		_space_ui.show_mid_message("This will warp the ship towards the celestial.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("It's available only if the celestial is far.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(5)
		_space_ui.show_mid_message("This will dock the ship to the station.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("If the station is far, it will warp to it first.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("If not in dock range, it will move to it first.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(6)
		_space_ui.show_mid_message("This will start mining the selected asteroid.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Only available if you select an asteroid.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Clicking this or the mining button is the same.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(7)
		_space_ui.show_mid_message("This will start show your ship info.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(8)
		_space_ui.show_mid_message("The RED BAR is your Hull integrity.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("If it reaches 0 your ship is destroyed.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("You will lose some credits to rebuild it.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(9)
		_space_ui.show_mid_message("The GREEN BAR shows your current speed.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("You'll also see your current action here.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(10)
		_space_ui.show_mid_message("The YELLOW BAR shows your cargo hold.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Moving the cursor on it will show more info.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(11)
		_space_ui.show_mid_message("Click this to mine the selected asteroid.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Click on it again to stop mining.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Remember you can't move during mining.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Put the cursor on it to show details.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(1)
		_space_ui.show_mid_message("It's time to dock the station.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")
		_space_ui.show_mid_message("Select <DC Mining Refinery> in the overview.")		
		yield(self, "tutorial_station_selected")
		_space_ui.show_mid_message("Good job.")
		yield(get_tree().create_timer(3.0*tutorial_speed), "timeout")	
		
		# Check it the player asked to skip the tutorial
		if (!is_tutorial_running):
			_space_ui.show_mid_message("Tutorial aborted.")
			return
		
		_space_ui.show_arrow(5)
		_space_ui.show_mid_message("Now click DOCK to dock the station.")
		yield(self, "tutorial_station_dock_selected")	
		
		#Make the arrow invisible now
		_space_ui.show_arrow(12)
		
		#Set account tritanium to 1 so the game scene tutorial  won't be shown again
		Globals.set_account_station_tritanium(1)
				
		# Tutorial is over
		is_tutorial_running = false
	else:
		is_first_login = false
		print("No tutorial time!")
		return		

func abort_tutorial() -> void:	
	is_tutorial_running = false
	
	#Set station tritanium to 2 it will also skip station tutorial
	Globals.set_account_station_tritanium(2)
	
	#Make the arrow invisible now
	_space_ui.show_arrow(12)
	
func _process(delta) -> void:
	update_space_ui()
	
	#Update the laserposition to the player position. It must not be parented or it will fail to work with rotations
	laser_beam_2d.global_position = _player.global_position# + Vector2(20,0)

func set_space_ui() -> void:
	_space_ui_speed.max_value = _player.movement_speed	
	
func update_space_ui() -> void:
	_space_ui_speed.value = clamp(_player.get_instant_velocity(), 0, _space_ui_speed.max_value)
	_space_ui_speed_labelms.text = str(_player.get_instant_velocity()) + " m/s"
	_space_ui_speed.hint_tooltip = "Current Speed is: " + str(_player.get_instant_velocity()) + " m/s"
	_space_ui_cargohold.max_value = _player.player_cargo_hold_capacity
	_space_ui_cargohold.value = clamp(_player.player_cargo_hold, 0, _player.player_cargo_hold_capacity)
	_space_ui_cargohold.hint_tooltip = "Cargo Hold has: [" + str(_player.player_cargo_hold) + " \\ " + str(_player.player_cargo_hold_capacity) + "m3] of Veldsar"
	_space_ui_hull.value = clamp(_player.player_hull_integrity, 0, 1000)
	_space_ui_hull.hint_tooltip = "Hull Integrity is: [" + str(_player.player_hull_integrity) + " \\ 1000]"
	
	if _player.get_instant_velocity() > 15 and not player_is_mining and not player_is_warping:
		_space_ui_action.text = "MOVING TO"
		_space_ui_target.text = "X: "+ str(round(_player.target_pos.x)) + " - Y: " + str(round(_player.target_pos.y))
	elif _player.get_instant_velocity() <= 15 and not player_is_mining and not player_is_warping:
		_space_ui_action.text = "STOPPED"
		_space_ui_target.text =  ""	
		_player.warping(false)	
	elif _player.get_instant_velocity() > 15 and player_is_warping:		
		_space_ui_action.text = "WARPING TO"
		_space_ui_target.text = get_selected_celestial().overview_name
		_space_ui_speed_labelms.text = str(_player.get_instant_velocity()/1000) + " km/s"		
		_player.warping(true)	
	elif not player_is_mining:
		_space_ui_action.text = "STOPPED"
		_space_ui_target.text =  ""		
		_player.warping(false)
		
	_space_ui_mining_button.hint_tooltip = _player.MINING_LASER.keys()[_player.player_mining_laser-1] + "\n\nCycle: " + str(_player.player_mining_laser_cycle) + " seconds\nRange: " + str(_player.player_mining_laser_range) + " m\nYield: [" + str(_player.player_mining_laser_yield) + " m3]"	
	
	# Update the overview
	update_overview_ui()
	
	# update selection box (distance)
	update_overview_selected()			

func create_overview_dictionary() -> void:
	# We need to add to overview dictionary all celestials that will compose our overview
	var celestials = get_tree().get_nodes_in_group("celestials")
	
	for celestial in celestials:
		overview[celestial.get_instance_id()] = celestial #Add node reference and instance id to the overview dictionary	

func create_new_overview_line_ui(celestial: Celestial) -> void:
	# Create a new row for the overview
	var space_label_x := Label.new()
	space_label_x.text = ""		
	space_label_x.name = str(celestial.get_instance_id()) + "_space_label"	# give the node a name reachable with the instance id (ID_node)
	var icon := TextureRect.new()				
	icon.texture = celestial.overview_icon
	icon.margin_right = 20
	icon.margin_bottom = 20	
	icon.rect_position.x = 4
	icon.rect_size.x = 16
	icon.rect_size.y = 20
	icon.name = str(celestial.get_instance_id()) + "_icon_texture"	# give the node a name reachable with the instance id (ID_node)
	var vsep_xa := VSeparator.new()
	vsep_xa.name = str(celestial.get_instance_id()) + "_vsep_a"	# give the node a name reachable with the instance id (ID_node)
	var distance_x := Label.new()
	distance_x.text = str(round(_player.position.distance_to(celestial.position))) + " m"
	distance_x.name = str(celestial.get_instance_id()) + "_distance_label"		# give the distance_x node a name reachable with the instance id
	distance_x.margin_left = 32
	distance_x.margin_top = 2
	distance_x.margin_right = 80
	distance_x.margin_bottom = 17
	distance_x.rect_size.x = 48
	distance_x.rect_size.y = 14
	var vsep_xb := VSeparator.new()
	vsep_xb.name = str(celestial.get_instance_id()) + "_vsep_b"	# give the node a name reachable with the instance id (ID_node)
	var name_x := Button.new()
	name_x.text = celestial.overview_name
	name_x.name = str(celestial.get_instance_id()) + "_name_label"	# give the node a name reachable with the instance id (ID_node)
	name_x.flat = true
	name_x.align = Button.ALIGN_LEFT
	name_x.margin_left = 92
	name_x.margin_right = 246
	name_x.margin_bottom = 20
	name_x.rect_position.x = 92
	name_x.rect_size.x = 154
	name_x.rect_size.y = 20
	name_x.rect_min_size.y = 14		
	name_x.connect("pressed", self, "_on_overview_selected", [celestial.get_instance_id()])		#instance id is the index for the signal callback
	_space_ui_overview_table.add_child(space_label_x)
	_space_ui_overview_table.add_child(icon)
	_space_ui_overview_table.add_child(vsep_xa)
	_space_ui_overview_table.add_child(distance_x)
	_space_ui_overview_table.add_child(vsep_xb)
	_space_ui_overview_table.add_child(name_x)	
	
func create_overview_ui() -> void:
	# This function will create the "TABLE" portion of the overview, creating as much items as needed
	# As the behaviour to read celestial isn't there yet, for now we'll programmatically create 10 elements instead
	
	# First remove the placeholder nodes
	for n in _space_ui_overview_table.get_children():
		_space_ui_overview_table.remove_child(n)		
	
	# First, get how many celestials we have
	#var celestial_number = overview.size()	
	
	for celestial in overview.values():
		# Create a new row for the overview
		var space_label_x := Label.new()
		space_label_x.text = ""		
		space_label_x.name = str(celestial.get_instance_id()) + "_space_label"	# give the node a name reachable with the instance id (ID_node)
		var icon := TextureRect.new()				
		icon.texture = celestial.overview_icon
		icon.margin_right = 20
		icon.margin_bottom = 20	
		icon.rect_position.x = 4
		icon.rect_size.x = 16
		icon.rect_size.y = 20
		icon.name = str(celestial.get_instance_id()) + "_icon_texture"	# give the node a name reachable with the instance id (ID_node)
		var vsep_xa := VSeparator.new()
		vsep_xa.name = str(celestial.get_instance_id()) + "_vsep_a"	# give the node a name reachable with the instance id (ID_node)
		var distance_x := Label.new()
		distance_x.text = str(round(_player.position.distance_to(celestial.position))) + " m"
		distance_x.name = str(celestial.get_instance_id()) + "_distance_label"		# give the distance_x node a name reachable with the instance id
		distance_x.margin_left = 32
		distance_x.margin_top = 2
		distance_x.margin_right = 80
		distance_x.margin_bottom = 17
		distance_x.rect_size.x = 48
		distance_x.rect_size.y = 14
		var vsep_xb := VSeparator.new()
		vsep_xb.name = str(celestial.get_instance_id()) + "_vsep_b"	# give the node a name reachable with the instance id (ID_node)
		var name_x := Button.new()
		name_x.text = celestial.overview_name
		name_x.name = str(celestial.get_instance_id()) + "_name_label"	# give the node a name reachable with the instance id (ID_node)
		name_x.flat = true
		name_x.align = Button.ALIGN_LEFT
		name_x.margin_left = 92
		name_x.margin_right = 246
		name_x.margin_bottom = 20
		name_x.rect_position.x = 92
		name_x.rect_size.x = 154
		name_x.rect_size.y = 20
		name_x.rect_min_size.y = 14		
		name_x.connect("pressed", self, "_on_overview_selected", [celestial.get_instance_id()])		#instance id is the index for the signal callback
		_space_ui_overview_table.add_child(space_label_x)
		_space_ui_overview_table.add_child(icon)
		_space_ui_overview_table.add_child(vsep_xa)
		_space_ui_overview_table.add_child(distance_x)
		_space_ui_overview_table.add_child(vsep_xb)
		_space_ui_overview_table.add_child(name_x)	

func update_overview_ui() -> void:
	for celestial in overview.values():	
		if (celestial.overview_visibile):
			var node = "SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + str(celestial.get_instance_id()) + "_distance_label"		
			var label = get_node(node) # the correct distance label in the overview
			
			var distance = get_distance_from_celestial(celestial)
			
			if label != null:
				# Check if it's a Warpable Celestial. Celestial are always shown
				if (celestial.warpable_to):
					var au_distance = distance/1000
					if (au_distance > 1):					
						label.text = str(au_distance) + " km"				
					else:
						label.text = str(distance) + " m"				
				else:
					#this is not a warpable celestial. As such, it should be visible only if it's under the overview_range
					if distance >= overview_range:
						# too far away, it should not be shown	
						celestial.overview_visibile = false				
						erase_element_from_overview(celestial.get_instance_id(), false)
					else:
						label.text = str(distance) + " m"					
			else:
				# We're trying to update the distance of a node not in the overview, maybe it's because it is now back in range
				if (distance < overview_range):
					celestial.overview_visibile = true
					create_new_overview_line_ui(celestial)	#add it again to the overview, maybe it was now back in range
				else:
					# It's out of range, it shouldn't be added yet, but check if it exists still
					# TODO CHECK IF THIS NEEDS TO BE REMOVED FOR GOOD
					pass
		else:
			# overview is not visible, but maybe it should?
			var distance = get_distance_from_celestial(celestial)
			if (distance < overview_range):
				celestial.overview_visibile = true
				create_new_overview_line_ui(celestial)	#add it again to the overview, maybe it was now back in range				

func move_player_manually(target_position = Vector2.ZERO) -> void:
	if player_is_mining:	# you shouldn't move while mining
		return
		
	if (target_position == Vector2.ZERO):		
		# Called without arguments, get mouse pos
		_player.target_pos = get_global_mouse_position()
	else:
		# Called with argument, get the passed position
		_player.target_pos = target_position
	
	# Before a manual move, the base offset should be restore
	_player.restore_regular_offset() 	
		
	#_player.first_target_set = true #allows the player to be moved. It needs to start false before any input or the player starting position would be accepted as a target to move			
	_player.face(_player.target_pos)
	#Set selection bool to false as this is a free move
	overview_selected = false		
	# Player is definitely not warping
	player_is_warping = false	
		
func _unhandled_input(event) -> void:
	if (is_tutorial_running):
		# The only unhandled input we accept when the tutorial is running is escape to skip it
		
		if Input.is_action_just_released("ui_cancel"):
			show_question_box("TUTORIAL", "Are you sure you want to skip the tutorial?", true, "_on_TUT_quit_yes", "_on_TUT_quit_no")	
	else:	
		if (_player.player_hull_integrity <= 0):
			# hide cursor so the player can't easily click on the overview
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			return
			
		if Input.is_action_pressed("left_click") and not player_is_mining: # Don't move if you're mining.
			#Desleect any selection
			selected_instance_id = 0
			_space_ui_overview_selection_text.text = "Nothing is selected."
			_space_ui_overview_selection_icon.texture = load("res://assets/art/ui/empty_icon.png")
			_space_ui.set_selection_buttons(false, false, false, false)		
			deselect_asteroids()
			# move there
			move_player_manually()
		elif Input.is_action_pressed("left_click") and player_is_mining:
			# player is trying to move, but we don't want to allow it, some feedback should be presented		
			$AUDIO/AURA_INSUFFICIENTPOWER.play()
			_space_ui.show_mid_message("Insufficient power to move. You are currently mining.")				

		if Input.is_action_just_released("zoom_out"):		
			#mouse_wheel down, zoom out
			var cur_zoom = _2dcamera.get_zoom()
			
			if cur_zoom.x < max_zoom_out:
				 #we're not too much zoomed out
				cur_zoom = Vector2(cur_zoom.x + 1, cur_zoom.y + 1)
				_2dcamera.set_zoom(cur_zoom)
				
		if Input.is_action_just_released("zoom_in"):		
			#mouse_wheel up, zoom in
			var cur_zoom = _2dcamera.get_zoom()		
			
			if cur_zoom.x > 1:						
				 #we're not too much zoomed in
				cur_zoom = Vector2(cur_zoom.x - 1, cur_zoom.y - 1)
				_2dcamera.set_zoom(cur_zoom)	
		
		if Input.is_action_just_released("ui_cancel"):
			show_question_box("QUITTING", "Are you sure you want to quit?", true, "_on_QB_quit_yes", "_on_QB_quit_no")	
		

func mine_asteroid() -> void:
	print("Minign time!")	
	
	if (selected_instance_id == 0):
		# you can't mine without sleceting something first
		_space_ui.show_mid_message("You cannot mine without an asteroid selected.")
		return
	
	_space_ui.show_mid_message("Beginning to mine.")
	
	# First we should check if we have an asteroid selected
	asteroid_being_mined = overview[selected_instance_id]
	
	if asteroid_being_mined.minable == false:
		# trying to mine something that isn't minable, really?
		return
	
	# OK we have our asteroid, before going anywhere else let's check if it's still there	
	if (asteroid_being_mined == null):
		print("The asteroid is no more!")
		return
	
	## Before starting the mining cycle, check if the ore hold is full
	if (_player.player_cargo_hold >= _player.player_cargo_hold_capacity):
		_space_ui.show_mid_message("Cargo hold is full.")
		player_is_mining = false
		return
	
	# Consider RANGE! If out of range, we can't mine! We should move closer instead.
	if (get_distance_from_celestial(asteroid_being_mined) >= _player.player_mining_laser_range):
		# this si too far, we can mine yet, move closer first	
		
		# before we start mining we need to wait until we're there!
		print("Moving to asteroid...")				
		#Change the offset distance to the player mining laser range
		
		# First save the current offset
		var current_offset = _player.offset_distance
		
		# Then update it to be the mining laser range
		_player.offset_distance = _player.player_mining_laser_range
		
		move_player_manually(asteroid_being_mined.global_position)
		yield(_player, "movement_completed")
		print("Asteroid reached...")			
		
		# retore previous offset
		_player.offset_distance = current_offset 
		
	print("Moved to an asteroid, now it can mineeeee it")
	# Ok, so we can get this show on the road after all. Start mining!
	
	# Set the target for the laser beam
	laser_beam_2d.beam_target = asteroid_being_mined.global_position
		
	_space_ui_mining_button.get_node("MiningBar").value = 0	
	if (DEBUG_SPEED_MINING == false):
		_space_ui_mining_button.get_node("MiningBar").max_value = _player.player_mining_laser_cycle
		_space_ui_mining_button.get_node("MiningCycle").wait_time = _player.player_mining_laser_cycle
	else:
		_space_ui_mining_button.get_node("MiningBar").max_value = 1
		_space_ui_mining_button.get_node("MiningCycle").wait_time = 1
	_space_ui_mining_button.get_node("MiningCycle").start()	
	
	# Star the laser
	laser_beam_2d.set_is_casting(true)
	print("turning ON the laser")
	
	# Udpat ethe UI to show the action
	_space_ui_action.text = "MINING"
	var mining_what = overview[asteroid_being_mined.get_instance_id()].overview_name
	_space_ui_target.text = mining_what	
	
	player_is_mining = true

## SPACE UI
func _on_SpaceUI_mining_button_pressed():
	if (not player_is_mining):
		mine_asteroid()
	else:
		# player is mining and wants to stop
		print("Player wants to stop mining.")
		laser_beam_2d.set_is_casting(false)	
		laser_beam_2d.disappear()
		_space_ui.show_mid_message("Mining stopped.")
		_space_ui_mining_button.get_node("MiningCycle").stop()
		_space_ui_mining_button.get_node("MiningBar").value = 0
		player_is_mining = false

func _on_SpaceUI_mining_cycle_completed() -> void:	
	# Cycle completed turn off the laser
	laser_beam_2d.set_is_casting(false)	
	
	# switch it on again
	laser_beam_2d.set_is_casting(true)	
	
	# First, get a reference to the selected object which we are mining
	var celestial = get_selected_celestial()
	
	# WARNING! The player might deselect it, and this will mess things up. Keep this in mind!
	# TODO: Handle deselection
	
	if (celestial == null):
		print("The asteroid is no more!")
		laser_beam_2d.set_is_casting(false)	
		return	
		
	# Time to mine it!
	celestial.get_mined(_player.player_mining_laser_yield)
	print("Veldspar remaining: " + str(celestial.ore_amount))
	
	# Get the mineral in the ore hold, unless it's full!
	if (_player.player_cargo_hold + _player.player_mining_laser_yield <= _player.player_cargo_hold_capacity):
		_player.player_cargo_hold += _player.player_mining_laser_yield
	else:
		print("Cargo hold full!!!")
		laser_beam_2d.set_is_casting(false)	
		_space_ui.show_mid_message("Cargo hold is full.")
		_space_ui_mining_button.get_node("MiningCycle").stop()
		_space_ui_mining_button.get_node("MiningBar").value = 0
		player_is_mining = false
		return	

## DEBUG! Probably we should link all asteroids (via code not inspectr) to this lone signal
func _on_VeldsparAsteroid_asteroid_depleted() -> void:
	# Cycle completed turn off the laser
	laser_beam_2d.set_is_casting(false)	
	print("Turning off the laser as asteroid is depleted")
	
	_space_ui_mining_button.get_node("MiningCycle").stop()
	_space_ui_mining_button.get_node("MiningBar").value = 0
		
	#remove this asteroid from the overview - it shoudl be the selected_instance_id
	erase_element_from_overview(selected_instance_id, true)
			
	#deselect
	selected_instance_id = 0
	
	# not mining anymore
	player_is_mining = false
	
	_space_ui.show_mid_message("The asteroid is depleted.")	
	
func erase_element_from_overview(instance: int, also_erase_from_dictionary: bool = false) -> void:
	if (also_erase_from_dictionary):
		# remove it from the overview dictionary	
		overview.erase(instance)
	
	var name_node_to_remove = str(instance) + "_name_label"
	var node_to_remove = get_node("SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + name_node_to_remove)	
	node_to_remove.queue_free()
	
	name_node_to_remove = str(instance) + "_space_label"
	node_to_remove = get_node("SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + name_node_to_remove)	
	node_to_remove.queue_free()
	
	name_node_to_remove = str(instance) + "_icon_texture"
	node_to_remove = get_node("SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + name_node_to_remove)	
	node_to_remove.queue_free()
	
	name_node_to_remove = str(instance) + "_vsep_a"
	node_to_remove = get_node("SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + name_node_to_remove)	
	node_to_remove.queue_free()
	
	name_node_to_remove = str(instance) + "_distance_label"
	node_to_remove = get_node("SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + name_node_to_remove)	
	node_to_remove.queue_free()
	
	name_node_to_remove = str(instance) + "_vsep_b"
	node_to_remove = get_node("SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + name_node_to_remove)	
	node_to_remove.queue_free()
	
func _on_overview_selected(index: int) -> void:
	# Store the instance id
	var instance_id = index
	
	# Get the reference to the celestial
	var celestial = overview[instance_id]
	
	# Set the target for player movement to this node (it's selected)
	_player.target_pos = celestial.global_position

	# Set selection bool
	overview_selected = true
	
	# Set the selection text	
	set_overview_selected_instance(instance_id)	
	
func set_overview_selected_instance(instance_id: int) -> void:
	# Get the reference node from the overview table
	var celestial = overview[instance_id]
	
	var name = 	celestial.overview_name

	# Calculate the distance
	var distance = get_distance_from_celestial(celestial) 
	#var distance = str(get_distance_from_celestial(celestial)) + " m"
	#var distance = str(round(_player.position.distance_to(celestial.position))) + " m"
	
	# If this is an asteroid we should also report the ore amount
	if celestial.minable == true:
		# Set the selection text to the node name and its distance and its ore contents
		_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance) + " m" + "\nOre: " + str(celestial.ore_amount)		
	else:
		# Set the selection text to the node name and its distance
		_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance) + " m"
	
	# Set the correct icon now
	_space_ui_overview_selection_icon.texture = celestial.overview_selection_icon
	
	# Set the instance id of the selected overview item
	selected_instance_id = instance_id
	
	# If it's an asteroid, select it
	if (celestial.minable or celestial.dockable):		
		#Deselect previously selected asteroids
		deselect_asteroids()
		
		# Selec this one
		celestial.selected(true)
		
		# Emit signal for tutorial
		emit_signal("tutorial_station_selected")

func set_player_target_to_selected_overview() -> void:
	if selected_instance_id != 0:
		# we have selected something	
		
		# Get the reference node from the overview table
		var celestial = get_selected_celestial()
		
		# Set the target for player movement to this node (it's selected)
		_player.target_pos = celestial.global_position
		
		# Set selection bool
		overview_selected = true
	else:
		# nothing has been seleted yet, so ignore this
		return	
	
func update_overview_selected() -> void:
	# This function will update whatever distance it finds in the node
	# Basically rather than setting a new slection given a intance id, this will update whatever is already there
	if selected_instance_id != 0:
		# we have selected something, update it
		
		# Get the reference node from the overview table
		var celestial = get_selected_celestial()
	
		var name = 	celestial.overview_name

		# Calculate the distance		
		#var distance = round(_player.position.distance_to(celestial.position))
		var distance = round(get_distance_from_celestial(celestial))
		
		# If this is an asteroid we should also report the ore amount
		if celestial.minable == true:			
			# Set the selection text to the node name and its distance and its ore contents
			_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance) + " m" + "\nOre: " + str(celestial.ore_amount)					
		else:
			# Set the selection text to the node name and its distance
			if (celestial.warpable_to):
				var au_distance = distance/1000
				if (au_distance > 1):
					_space_ui_overview_selection_text.text = name + "\nDistance: " + str(au_distance) + " km"
				else:
					_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance) + " m"
			
		# Now we must set the Selection Box Buttons
		
		# Check if a warpable celestial is "far enough" to initiate a warp
		var truly_warpable = false
		if (celestial.warpable_to == true and get_distance_from_celestial(celestial) >= _player.warp_threashold):
			truly_warpable = true
		else:
			truly_warpable = false
							
		_space_ui.set_selection_buttons(celestial.movable_to, truly_warpable, celestial.dockable, celestial.minable)
		
	else:
		# nothing has been seleted, let's clear this		
		_space_ui_overview_selection_text.text = "Nothing is selected."
		_space_ui_overview_selection_icon.texture = load("res://assets/art/ui/empty_icon.png")
		_space_ui.set_selection_buttons(false, false, false, false)
		deselect_asteroids()		
		return	

func deselect_asteroids() -> void:
	var celestials = get_tree().get_nodes_in_group("celestials")
	
	for celestial in celestials:
		if celestial.minable or celestial.dockable and celestial.is_selected():
			celestial.selected(false)

func get_selected_celestial() -> Celestial:
	if selected_instance_id != 0:
		return overview[selected_instance_id]
	else:		
		return null
		
func get_distance_from_celestial(celestial: Celestial) -> int:	
	return int(round(_player.position.distance_to(celestial.position)))	

## OVERVIEW CALLBACKS
func _on_SpaceUI_overview_move_to() -> void:
	if (player_is_mining):
		#the player is mining, an official move to action should abort the mining process
		print("Now we should abort mining and do nothing else")
		return
	
	if (overview_selected and get_selected_celestial().movable_to == true):
		# Adjust the offset for the move action (a station is much bigger)
		_player.offset_distance = get_selected_celestial().offset_distance
		_player.face(_player.target_pos)
		player_is_warping = false
		_player.warping(false)
	else:
		# player moved somewhere else manually, we need to 
		# refresh the target_pos to the previously (and currently) selected overview 
		set_player_target_to_selected_overview()
		
		#  now go!
		_player.face(_player.target_pos)
		player_is_warping = false
		_player.warping(false)

func dock() -> void:
	emit_signal("tutorial_station_dock_selected")
	
	_space_ui.show_mid_message("Docking permission requested...")				
	$AUDIO/AURA_DOCKINGREQUESTED.play()
	
	#wait for the request to finish...
	yield($AUDIO/AURA_DOCKINGREQUESTED, "finished")
	
	# ACCEPT REQUEST
	$AUDIO/AURA_DOCKINGACCEPTED.play()
	
	_space_ui.show_mid_message("Docking request accepted.")	
	
	#wait for the request to finish...
	yield($AUDIO/AURA_DOCKINGACCEPTED, "finished")	
	
	#Transition to login scene as a test
	
	#Save file before docking
	# We're passing station tritanium already in the globals as we don't need to save it when docking, it's already there
	Globals.save_to_Globals(_player.player_credits, _player.player_mining_laser, _player.player_cargo_extender, _player.player_cargo_hold, _player.global_position, Globals.get_account_station_tritanium())
	if (Globals.save()):
		# All good, dock now!
		_transition_rect.transition_to("res://source/Main/StationScene.tscn")
	else:
		# save() failed or didn't complete!		
		printerr("Failed to save, aborting dock sequence.")
		$AUDIO/AURA_DOCKINGDENIED.play()		
		_space_ui.show_mid_message("Docking request denied.")	
		return
	

func _on_SpaceUI_overview_dock_to() -> void:	
	var selected_celestial = get_selected_celestial()
	
	# first check if the selected celestial is dockable
	if (overview_selected and selected_celestial.dockable == true):
		# if it is, check the distance.
		if (get_distance_from_celestial(selected_celestial) <= selected_celestial.docking_range):
			dock()
		else:				
			# it's too far. Check if it's in warping distance			
			var distance = round(_player.position.distance_to(selected_celestial.position))
			if distance >= _player.warp_threashold:	
				warp_to_celestial(selected_celestial)
			else:
				_space_ui.show_mid_message("Moving to station...")	
				# we're not far enough for a warp, move it it instead
				_player.offset_distance = get_selected_celestial().offset_distance
				_player.face(_player.target_pos)
				player_is_warping = false
				_player.warping(false)
				
			# Wait for it to reach the station
			yield(_player, "movement_completed")	
			dock()
	else:
		# player tried to dock on something not dockable, tecnically not possible
		print("Player is docking on something not dockable.")

func _on_SpaceUI_overview_mine_to() -> void:
	if (not player_is_mining):
		mine_asteroid()
	else:
		# player is mining and wants to stop
		print("Player wants to stop mining.")
		laser_beam_2d.set_is_casting(false)	
		laser_beam_2d.disappear()
		_space_ui.show_mid_message("Mining stopped.")
		_space_ui_mining_button.get_node("MiningCycle").stop()
		_space_ui_mining_button.get_node("MiningBar").value = 0
		player_is_mining = false

func warp_to_celestial(celestial: Celestial) -> void:
	# First check if the selected celestial is warpable
	if (overview_selected and celestial.warpable_to == true):
		# Then check if it's distant enough to initiate a warp sequence
		var distance = round(_player.position.distance_to(celestial.position))
		if distance >= _player.warp_threashold:	
			# Set the offset distance so you don't get inside of it...
			_player.offset_distance = celestial.offset_distance
						
			# initaite warp
			_space_ui.show_mid_message("WARP DRIVE ACTIVE.")
			$AUDIO/AURA_WARPDRIVEACTIVE.play()
			player_is_warping = true
			_player.warping(true)
			_player.face(_player.target_pos, true)
		else:
			# can't warp, it's too close			
			_space_ui.show_mid_message("Attempting to warp to a closeby celestial.")
			return

func _on_SpaceUI_overview_warp_to() -> void:
	warp_to_celestial(get_selected_celestial())
			
# Callbacks for QuestionBox: QUITTING YES
func _on_QB_quit_yes():
	#Save file before quitting
	#For station tritanium we don'th ave it saved on the player as it is not used outside of stations, so we save what's already in the globals (station trit cannot be changed outside of the station so there's no danger the value might change)
	Globals.save_to_Globals(_player.player_credits, _player.player_mining_laser, _player.player_cargo_extender, _player.player_cargo_hold, _player.global_position, Globals.get_account_station_tritanium())
	if (Globals.save()):
		get_tree().quit()
	else:
		# save() failed or didn't complete, shall we try again?
		# we don't allow qutting if save fails
		printerr("Save failed. I won't allow you to quit. Try again.")
	
# Callbacks for QuestionBox: QUITTING NO
func _on_QB_quit_no():
	#arlight then
	pass

#Callbacks for QUestionBox: TUTORIAL SKIP YES
func _on_TUT_quit_yes():
	abort_tutorial()
	
#Callbacks for QUestionBox: TUTORIAL SKIP NO
func _on_TUT_quit_no():
	#alright then
	pass

func show_question_box(title, message, centered, callback_yes, callback_no) -> void:
	# Clear the QuestionBox singla connections first	
	_question_box.clear_connections()
	
	# Connect the signals to the specified callbacks
	_question_box.connect("yes_button_pressed", self, callback_yes)	
	_question_box.connect("no_button_pressed", self, callback_no)	
	
	# Show the question box
	_question_box.set_message(title, message)
	if centered:
		_question_box.popup_centered()
	else:
		_question_box.popup()


func _on_Player_death() -> void:
	$LaserBeam2D.hide()
	_space_ui.show_mid_message("You have been destroyed.")	
	
	yield(get_tree().create_timer(3.0), "timeout")
	
	var destruction_penalty = _player.player_credits / 100 * player_destruction_credit_percentage_penalty
	
	_space_ui.show_mid_message("You lost " + str(destruction_penalty) + " credits.")
	
	_player.player_credits = _player.player_credits - destruction_penalty
	
	yield(get_tree().create_timer(4.0), "timeout")
	
	# Dock the station
	Globals.save_to_Globals(_player.player_credits, _player.player_mining_laser, _player.player_cargo_extender, _player.player_cargo_hold, Vector2.ZERO, Globals.get_account_station_tritanium())
	if (Globals.save()):
		# All good, go to login now
		_transition_rect.transition_to("res://source/Main/StationScene.tscn")
	else:
		# save() failed or didn't complete!		
		printerr("Failed to save, aborting!")			
		_space_ui.show_mid_message("Error. This shouldn't happen...")		

func _on_space_anomaly_chasing() -> void:
	if (_player.player_hull_integrity > 0):
		_space_ui.show_mid_message("Warning. Space Anomaly approaching.")

func _on_Player_hurt() -> void:
	if (_player.player_hull_integrity > 0):
		_space_ui.show_mid_message("Hull integrity falling.")
