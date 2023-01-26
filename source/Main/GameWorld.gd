extends Node2D

onready var _player = $Player
onready var _space_ui = $SpaceUI
onready var _space_ui_cargohold = $SpaceUI/LowerHUD/CargoHold
onready var _space_ui_speed = $SpaceUI/LowerHUD/Speed
onready var _space_ui_hull = $SpaceUI/LowerHUD/HullIntegrity
onready var _space_ui_action = $SpaceUI/LowerHUD/LabelAction
onready var _space_ui_target = $SpaceUI/LowerHUD/LabelActionTarget



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
