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
onready var _space_ui_overview_table = $SpaceUI/OverviewHUD/VBoxContainer/TABLE
onready var _props = $Props

# DEBUGGING
const max_zoom_out = 10

func _ready() -> void:
	# Loads player variables
	_player.SetPlayer(Globals.get_account_credits(), Globals.get_account_mininglaser(), Globals.get_account_cargoextender(), Globals.get_account_cargohold(), Globals.get_account_position())	
	
	# Set initial space_ui
	set_space_ui()
	
	# Load overview
	load_overview()
	
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
	
	if _player.get_instant_velocity() > 0:
		_space_ui_action.text = "MOVING"
		_space_ui_target.text = "X: "+ str(round(_player.target_pos.x)) + " - Y: " + str(round(_player.target_pos.y))
	else:
		_space_ui_action.text = "STOPPED"
		_space_ui_target.text =  ""		
		
	_space_ui_mining_button.hint_tooltip = _player.MINING_LASER.keys()[_player.player_mining_laser] + "\n\nCycle: " + str(_player.player_mining_laser_cycle) + " seconds\nRange: " + str(_player.player_mining_laser_range) + " km\nYield: [" + str(_player.player_mining_laser_yield) + " m3]"	
	
	load_overview()

func load_overview() -> void:
	var counter = 1
	for asteroid in _props.get_children():
		if counter <= 7:
			var node_name: String = ""
			var node_distance: String = ""
			node_name = "NAME"+str(counter)
			node_distance = "DISTANCE"+str(counter)
			_space_ui_overview_table.get_node(node_name).text = asteroid.name			
			_space_ui_overview_table.get_node(node_distance).text = str(round(_player.position.distance_to(asteroid.position))) + " m"
		counter = counter + 1	
		
func _input(event) -> void:#	
	if Input.is_action_pressed("left_click") and _space_ui.hovering_on_gui() != true:
		_player.target_pos = get_global_mouse_position()
		#_player.first_target_set = true #allows the player to be moved. It needs to start false before any input or the player starting position would be accepted as a target to move			
		_player.face(_player.target_pos)

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
	_space_ui_mining_button.get_node("MiningBar").value = 0	
	_space_ui_mining_button.get_node("MiningBar").max_value = _player.player_mining_laser_cycle
	_space_ui_mining_button.get_node("MiningCycle").start()
