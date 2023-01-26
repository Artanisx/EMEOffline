extends Node2D

onready var _player = $Player
onready var _2dcamera = $Player/Camera2D
onready var _space_ui = $SpaceUI
onready var _space_ui_cargohold = $SpaceUI/LowerHUD/CargoHold
onready var _space_ui_speed = $SpaceUI/LowerHUD/Speed
onready var _space_ui_hull = $SpaceUI/LowerHUD/HullIntegrity
onready var _space_ui_action = $SpaceUI/LowerHUD/LabelAction
onready var _space_ui_target = $SpaceUI/LowerHUD/LabelActionTarget
onready var _space_ui_mining_button = $SpaceUI/LowerHUD/MiningButton

# DEBUGGING
const max_zoom_out = 10

func _ready() -> void:
	# Loads player variables
	_player.SetPlayer(Globals.get_account_credits(), Globals.get_account_mininglaser(), Globals.get_account_cargoextender(), Globals.get_account_cargohold(), Globals.get_account_position())	
	
func _process(delta) -> void:
	update_space_ui()
	
func update_space_ui() -> void:
	_space_ui_speed.value = clamp(int($Player.velocity.length()), 0, 100)
	_space_ui_cargohold.value = clamp($Player.player_cargo_hold, 0, $Player.player_cargo_hold_capacity)
	_space_ui_hull.value = clamp($Player.player_hull_integrity, 0, 1000)
	
	if $Player.velocity.length() > 0:
		_space_ui_action.text = "MOVING"
		_space_ui_target.text = "X: "+ str(round($Player.target.x)) + " - Y: " + str(round($Player.target.y))
	else:
		_space_ui_action.text = "STOPPED"
		_space_ui_target.text =  ""
		
func _input(event) -> void:
	if _player.movement_mode == "Turtle":
		if Input.is_action_just_released("left_click") and _space_ui.mining_button_hover != true:
			_player.target_mouse_position  = get_global_mouse_position()
	elif (_player.movement_mode == "Direct"):
		_player.velocity = Vector2()
		
		if Input.is_action_pressed("ui_right"):
			_player.velocity.x += 1
		
		if Input.is_action_pressed("ui_left"):
			_player.velocity.x -= 1
		
		if Input.is_action_pressed("ui_down"):
			_player.velocity.y += 1
		
		if Input.is_action_pressed("ui_up"):
			_player.velocity.y -= 1	
			
		if _player.velocity.length() > 0:
			_player.velocity = _player.velocity.normalized() * _player.speed
	elif (_player.movement_mode == "RTS" or _player.movement_mode == "Missile"):
		if Input.is_action_pressed("left_click") and _space_ui.mining_button_hover != true:
			_player.target = get_global_mouse_position()
			_player.first_target_set = true #allows the player to be moved. It needs to start false before any input or the player starting position would be accepted as a target to move			

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

