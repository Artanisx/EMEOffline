extends PopupDialog

onready var _market_logo: TextureRect = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MarketLogo
onready var _market_title: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MarketTitle
onready var _market_ui_table: GridContainer = $Panel/MarginContainer/VBoxContainer/GridContainer

var market_mode: String = ""
var current_credits: int = 0
var current_mining_laser: int = 1
var current_cargo_expander: int = 0

signal upgrade_complete
signal send_message

# Set the Market UI and pass relevant data
# As default it will prepare a Mining Laser market
# It will also have default values for everything so you can only pass the relevant data which should be credits
func set_market(market_mode: String = "MiningLaser", cur_creds: int = 0, cur_mining_laser = Globals.get_account_mininglaser(), cur_cargo_ext = Globals.get_account_cargoextender()) -> void:
	# First we clear out the placeholder nodes
	for n in _market_ui_table.get_children():
		_market_ui_table.remove_child(n)	
		
	# For now we call it a day

func _on_CloseButton_pressed() -> void:
	hide()
