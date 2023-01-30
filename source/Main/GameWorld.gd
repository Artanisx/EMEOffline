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
onready var _props = $Props

# OVERVIEW
var overview = {}
#var celestial: Celestial = Celestial.new()

var overview_selected: bool = false
var overview_selected_index = 0
var button_clicked: bool = false

# DEBUGGING
const max_zoom_out = 10
export var proto_overview: bool = true
var warnings_given: bool = false
var DEBUG_SPEED_MINING: bool = true

func _ready() -> void:	
	# Loads player variables
	_player.SetPlayer(Globals.get_account_credits(), Globals.get_account_mininglaser(), Globals.get_account_cargoextender(), Globals.get_account_cargohold(), Globals.get_account_position())	
	
	# Set initial space_ui
	set_space_ui()
	
	# Populate OVERVIEW dictionary as needed
	create_overview_dictionary()
	
	# Create Overview UI, adding rows as required
	create_overview_ui()
	
	# Load overview
	load_overview_proto()
	
func _process(delta) -> void:
	update_space_ui()
	
	### CHECK FOR WARNINGS
	if proto_overview == false and warnings_given == false:
		printerr("[WARNING] PROTO OVERVIEW IS DISABLED")
		warnings_given = true		

func set_space_ui() -> void:
	_space_ui_speed.max_value = _player.movement_speed	
	
func update_space_ui() -> void:
	_space_ui_speed.value = clamp(_player.get_instant_velocity(), 0, _space_ui_speed.max_value)
	_space_ui_speed_labelms.text = str(_player.get_instant_velocity()) + " m/s"
	_space_ui_speed.hint_tooltip = "Current Speed is: " + str(_player.get_instant_velocity()) + " m/s"
	_space_ui_cargohold.value = clamp(_player.player_cargo_hold, 0, _player.player_cargo_hold_capacity)
	_space_ui_cargohold.hint_tooltip = "Cargo Hold has: [" + str(_player.player_cargo_hold) + " \\ " + str(_player.player_cargo_hold_capacity) + "m3] of Veldsar"
	_space_ui_hull.value = clamp(_player.player_hull_integrity, 0, 1000)
	_space_ui_hull.hint_tooltip = "Hull Integrity is: [" + str(_player.player_hull_integrity) + " \\ 1000]"
	
	if _player.get_instant_velocity() > 0:
		_space_ui_action.text = "MOVING"
		_space_ui_target.text = "X: "+ str(round(_player.target_pos.x)) + " - Y: " + str(round(_player.target_pos.y))
	else:
		_space_ui_action.text = "STOPPED"
		_space_ui_target.text =  ""		
		
	_space_ui_mining_button.hint_tooltip = _player.MINING_LASER.keys()[_player.player_mining_laser] + "\n\nCycle: " + str(_player.player_mining_laser_cycle) + " seconds\nRange: " + str(_player.player_mining_laser_range) + " km\nYield: [" + str(_player.player_mining_laser_yield) + " m3]"	
	
	# Update the overview
	update_overview_ui()
	
	# update selection box (distance)	
	update_overview_selection_text_distance(overview_selected_index)			

func create_overview_dictionary() -> void:
	# We need to add to overview dictionary all celestials that will compose our overview
	var celestials = get_tree().get_nodes_in_group("celestials")
	
	for celestial in celestials:
		overview[celestial.get_instance_id()] = celestial #Add node reference and instance id to the overview dictionary	
	
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
		var icon := TextureRect.new()
		print(celestial.overview_icon)
		icon.texture = celestial.overview_icon
		icon.margin_right = 20
		icon.margin_bottom = 20	
		icon.rect_position.x = 4
		icon.rect_size.x = 16
		icon.rect_size.y = 20
		var vsep_xa := VSeparator.new()
		var distance_x := Label.new()
		distance_x.text = str(round(_player.position.distance_to(celestial.position))) + " m"
		distance_x.name = str(celestial.get_instance_id()) + "distance"		# give the distance_x node a name reachable with the instance id
		distance_x.margin_left = 32
		distance_x.margin_top = 2
		distance_x.margin_right = 80
		distance_x.margin_bottom = 17
		distance_x.rect_size.x = 48
		distance_x.rect_size.y = 14
		var vsep_xb := VSeparator.new()
		var name_x := Button.new()
		name_x.text = celestial.overview_name
		name_x.flat = true
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
		var node = "SpaceUI/OverviewHUD/VBoxContainer/ScrollContainer/TABLE/" + str(celestial.get_instance_id()) + "distance"		
		var label = get_node(node) # the correct distance label in the overview
		label.text = str(round(_player.position.distance_to(celestial.position))) + " m"

func load_overview_proto() -> void:
	## DEBUGGING
	if proto_overview == false:		
		return
	## END DEBUGGING
		
	var counter = 1
	for asteroid in _props.get_children():
		if counter <= 7:
			var node_name: String = ""
			var node_distance: String = ""
			node_name = "NAME"+str(counter)
			node_distance = "DISTANCE"+str(counter)
			_space_ui_overview_table.get_node(node_name).text = asteroid.name					
			_space_ui_overview_table.get_node(node_distance).text = str(round(_player.position.distance_to(asteroid.position))) + " m"
			overview[asteroid.name] = asteroid	#Add node and name to the overview dictionary
		counter = counter + 1	

func update_overview_selection_text_distance(index: int) -> Node2D:	
	## DEBUGGING
	if (proto_overview == false):		
		return null
	## END DEBUGGING	
	
	# This function updates the sleection text in the overview, getting name and calculating distance
	# We pass an index, the number of the item in the overview from 1 to 7
	# 0 is not valid, it means nothing is selected
	
	if index == 0:
		return null

	var node_name = "NAME"+str(index)

	# Get the reference node from the overview table
	var reference = overview[_space_ui_overview_table.get_node(node_name).text]

	# Calculate the distance
	var distance = str(round(_player.position.distance_to(reference.position))) + " m"

	# Set the selection text to the node name and its distance
	_space_ui_overview_selection_text.text = _space_ui_overview_table.get_node("NAME1").text + "\nDistance: " + str(distance)
	
	return reference
		
func _unhandled_input(event) -> void:#	
	if Input.is_action_pressed("left_click"):# and _space_ui.hovering_on_gui() != true and button_clicked == false:
		_player.target_pos = get_global_mouse_position()
		#_player.first_target_set = true #allows the player to be moved. It needs to start false before any input or the player starting position would be accepted as a target to move			
		_player.face(_player.target_pos)
		#Set selection bool to false as this is a free move
		overview_selected = false
	
	if Input.is_action_pressed("ui_left"):
		print("LEFTTT")

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
		get_tree().quit()


## SPACE UI
func _on_SpaceUI_mining_button_pressed():
	print("Minign time!")
	if ($VeldsparAsteroid == null):
		print("The asteroid is no more!")
		return
	
	## Before starting the mining cycle, check if the ore hold is full
	if (_player.player_cargo_hold >= _player.player_cargo_hold_capacity):
		print("Cargo hold is full")
		return
		
	_space_ui_mining_button.get_node("MiningBar").value = 0	
	if (DEBUG_SPEED_MINING == false):
		_space_ui_mining_button.get_node("MiningBar").max_value = _player.player_mining_laser_cycle
		_space_ui_mining_button.get_node("MiningCycle").wait_time = _player.player_mining_laser_cycle
	else:
		_space_ui_mining_button.get_node("MiningBar").max_value = 1
		_space_ui_mining_button.get_node("MiningCycle").wait_time = 1
	_space_ui_mining_button.get_node("MiningCycle").start()	

func _on_SpaceUI_overview_name1_selected() -> void:	
	## DEBUGGING
	if (proto_overview == false):		
		return
	## END DEBUGGING	
	
	# Set the Selection text with node and distance, plus store a reference to the node itself
	var reference = update_overview_selection_text_distance(1)
	
	# Set the target for player movement to this node (it's selected)
	_player.target_pos = reference.global_position

	#Set selection bool
	overview_selected = true
	
	#Set the selected index so load_overview knows what to update for the distance	
	overview_selected_index = 1
		

func _on_SpaceUI_overview_move_to() -> void:
	if (overview_selected):
		_player.face(_player.target_pos)
	else:
		# player moved somewhere else, we must refresh the selection first
		#for now assume selection 1 since it's the only one rigged in
		_on_SpaceUI_overview_name1_selected()
		
		#  now go!
		_player.face(_player.target_pos)

func _on_SpaceUI_mining_cycle_completed() -> void:
	#DEBUG! Mine the only veldsar!
	if ($VeldsparAsteroid == null):
		print("The asteroid is no more!")
		return
	$VeldsparAsteroid.get_mined(100)
	print("Veldspar remaining: " + str($VeldsparAsteroid.ore_amount))
	
	if (_player.player_cargo_hold + 100 <= _player.player_cargo_hold_capacity):
		_player.player_cargo_hold += 100
	else:
		print("Cargo hold full!!!")
		_space_ui_mining_button.get_node("MiningCycle").stop()
		_space_ui_mining_button.get_node("MiningBar").value = 0
		return

## DEBUG! Probably we should link all asteroids (via code not inspectr) to this lone signal
func _on_VeldsparAsteroid_asteroid_depleted() -> void:
	_space_ui_mining_button.get_node("MiningCycle").stop()
	_space_ui_mining_button.get_node("MiningBar").value = 0
	
func _on_overview_selected(index: int) -> void:
	print("Button " + str(index) + " pressed")
	button_clicked = true # so it doesn't move the ship?
	
