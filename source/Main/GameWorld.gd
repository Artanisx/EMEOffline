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

# OVERVIEW
var overview = {}
#var celestial: Celestial = Celestial.new()

var overview_selected: bool = false
var overview_selected_index = 0
var button_clicked: bool = false
var selected_instance_id: int = 0	#when an item is selceted in the overview, this holds the instance_id of the node
var player_is_mining: bool = false
var player_is_warping: bool = false

## Celestial over this distance will not be shown in the overview
export var overview_range: int = 5000 

# DEBUGGING
const max_zoom_out = 10
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
	
func _process(delta) -> void:
	update_space_ui()

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
		_player.warping(true)	
	elif not player_is_mining:
		_space_ui_action.text = "STOPPED"
		_space_ui_target.text =  ""		
		_player.warping(false)
		
	_space_ui_mining_button.hint_tooltip = _player.MINING_LASER.keys()[_player.player_mining_laser] + "\n\nCycle: " + str(_player.player_mining_laser_cycle) + " seconds\nRange: " + str(_player.player_mining_laser_range) + " km\nYield: [" + str(_player.player_mining_laser_yield) + " m3]"	
	
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
		
func _unhandled_input(event) -> void:#	
	if Input.is_action_pressed("left_click"):# and _space_ui.hovering_on_gui() != true and button_clicked == false:
		_player.target_pos = get_global_mouse_position()
		#_player.first_target_set = true #allows the player to be moved. It needs to start false before any input or the player starting position would be accepted as a target to move			
		_player.face(_player.target_pos)
		#Set selection bool to false as this is a free move
		overview_selected = false		
		# Player is definitely not warping
		player_is_warping = false
	
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
	
	# First we should check if we have an asteroid selected
	var celestial = overview[selected_instance_id]
	
	if celestial.minable == false:
		# trying to mine something that isn't minable, really?
		return
	
	# OK we have our asteroid, before going anywhere else let's check if it's still there	
	if (celestial == null):
		print("The asteroid is no more!")
		return
	
	## Before starting the mining cycle, check if the ore hold is full
	if (_player.player_cargo_hold >= _player.player_cargo_hold_capacity):
		print("Cargo hold is full")
		return
	
	# TODO Consider RANGE! If out of range, we can't mine! We should move closer instead.	
	
	# Ok, so we can get this show on the road after all. Start mining!
		
	_space_ui_mining_button.get_node("MiningBar").value = 0	
	if (DEBUG_SPEED_MINING == false):
		_space_ui_mining_button.get_node("MiningBar").max_value = _player.player_mining_laser_cycle
		_space_ui_mining_button.get_node("MiningCycle").wait_time = _player.player_mining_laser_cycle
	else:
		_space_ui_mining_button.get_node("MiningBar").max_value = 1
		_space_ui_mining_button.get_node("MiningCycle").wait_time = 1
	_space_ui_mining_button.get_node("MiningCycle").start()	
	
	# Udpat ethe UI to show the action
	_space_ui_action.text = "MINING"
	var mining_what = overview[selected_instance_id].overview_name
	_space_ui_target.text = mining_what	
	
	player_is_mining = true



func _on_SpaceUI_mining_cycle_completed() -> void:	
	# First, get a reference to the selected object which we are mining
	var celestial = get_selected_celestial()
	
	# WARNING! The player might deselect it, and this will mess things up. Keep this in mind!
	# TODO: Handle deselection
	
	if (celestial == null):
		print("The asteroid is no more!")
		return	
		
	# Time to mine it!
	celestial.get_mined(_player.player_mining_laser_yield)
	print("Veldspar remaining: " + str(celestial.ore_amount))
	
	# Get the mineral in the ore hold, unless it's full!
	if (_player.player_cargo_hold + _player.player_mining_laser_yield <= _player.player_cargo_hold_capacity):
		_player.player_cargo_hold += _player.player_mining_laser_yield
	else:
		print("Cargo hold full!!!")
		_space_ui_mining_button.get_node("MiningCycle").stop()
		_space_ui_mining_button.get_node("MiningBar").value = 0
		return

## DEBUG! Probably we should link all asteroids (via code not inspectr) to this lone signal
func _on_VeldsparAsteroid_asteroid_depleted() -> void:
	_space_ui_mining_button.get_node("MiningCycle").stop()
	_space_ui_mining_button.get_node("MiningBar").value = 0
		
	#remove this asteroid from the overview - it shoudl be the selected_instance_id
	erase_element_from_overview(selected_instance_id)
			
	#deselect
	selected_instance_id = 0
	
	# not mining anymore
	player_is_mining = false
	
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
	var distance = str(round(_player.position.distance_to(celestial.position))) + " m"
	
	# If this is an asteroid we should also report the ore amount
	if celestial.minable == true:
		# Set the selection text to the node name and its distance and its ore contents
		_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance) + "\nOre: " + str(celestial.ore_amount)		
	else:
		# Set the selection text to the node name and its distance
		_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance)
	
	# Set the correct icon now
	_space_ui_overview_selection_icon.texture = celestial.overview_selection_icon
	
	# Set the instance id of the selected overview item
	selected_instance_id = instance_id

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
		var distance = str(round(_player.position.distance_to(celestial.position))) + " m"
		
		# If this is an asteroid we should also report the ore amount
		if celestial.minable == true:
			# Set the selection text to the node name and its distance and its ore contents
			_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance) + "\nOre: " + str(celestial.ore_amount)		
		else:
			# Set the selection text to the node name and its distance
			_space_ui_overview_selection_text.text = name + "\nDistance: " + str(distance)
			
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
		return	

func get_selected_celestial() -> Celestial:
	if selected_instance_id != 0:
		return overview[selected_instance_id]
	else:		
		return null
		
func get_distance_from_celestial(celestial: Celestial) -> int:	
	return int(round(_player.position.distance_to(celestial.position)))	

## OVERVIEW CALLBACKS
func _on_SpaceUI_overview_move_to() -> void:
	if (overview_selected and get_selected_celestial().movable_to == true):
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

func _on_SpaceUI_overview_dock_to() -> void:
	# first check if the selected celestial is dockable
	
	# if it is, check the distance.
	
	# if it's too far, Warp to it first, then dock
	
	# if it close (500m?) dock right away
	
	pass # Replace with function body.


func _on_SpaceUI_overview_mine_to() -> void:
	# First check if the selected celestial is minable
	
	# Then check if it's in range
	
	# if it is, start mining
	
	# if it isn't, move to until it is in range
	
	# and then mine it
	pass

func _on_SpaceUI_overview_warp_to() -> void:
	#First checkif the selected celestial is warpable
	if (overview_selected and get_selected_celestial().warpable_to == true):
		# THen check if it's distant enough to initiate a warp sequence
		var distance = round(_player.position.distance_to(get_selected_celestial().position))
		if distance >= _player.warp_threashold:
			# initaite warp
			$AUDIO/AURA_WARPDRIVEACTIVE.play()
			player_is_warping = true
			_player.warping(true)
			_player.face(_player.target_pos, true)			
		else:
			# can't warp, it's too close
			print("Attempting to warp to a too closeby celestial.")
			return
