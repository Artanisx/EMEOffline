extends PopupDialog

onready var _market_logo: TextureRect = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MarketLogo
onready var _market_title: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MarketTitle
onready var _market_ui_table: GridContainer = $Panel/MarginContainer/VBoxContainer/GridContainer

var mining_laser_icon = load("res://assets/art/ui/station_button_mininglaser_normal.png")	
var cargo_ext_icon = load("res://assets/art/ui/station_button_cargoexpander_normal.png")

var market_mode: String = ""
var current_credits: int = 0
var current_mining_laser: int = 1
var current_cargo_expander: int = 0

const mining_laser_II_cost = 60000
const mining_laser_III_cost = 90000
const mining_laser_IV_cost = 180000
const mining_laser_V_cost = 250000

signal upgrade_complete
signal send_message

# Set the Market UI and pass relevant data
# As default it will prepare a Mining Laser market
# It will also have default values for everything so you can only pass the relevant data which should be credits
func set_market(market_mode: String = "MiningLaser", cur_creds: int = 0, cur_mining_laser = Globals.get_account_mininglaser(), cur_cargo_ext = Globals.get_account_cargoextender()) -> void:
	# First we clear out the placeholder nodes
	for n in _market_ui_table.get_children():
		_market_ui_table.remove_child(n)
		
	# Set variables
	current_credits = cur_creds
	current_mining_laser = cur_mining_laser
	current_cargo_expander = cur_cargo_ext
		
	if (market_mode == "MiningLaser"):
		set_mode_mining_laser()
	else:
		set_mode_cargo_extender()

func set_mode_mining_laser() -> void:
	# For mining lasers we have 4, from Mining Laser II to Mining Laser V so we need 4 rows
	for x in 4:
		var icon := TextureRect.new()				
		icon.texture = mining_laser_icon
		icon.margin_right = 68
		icon.margin_bottom = 68			
		icon.rect_size.x = 68
		icon.rect_size.y = 68		
		
		var name := Label.new()
		
		match x:
			0:
				name.text = "MINING LASER II"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_mining_laser == 2):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
			1:
				name.text = "MINING LASER III"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_mining_laser == 3):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
			2:
				name.text = "MINING LASER IV"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_mining_laser == 4):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
			3:
				name.text = "MINING LASER V"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_mining_laser == 5):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
				
		name.margin_left = 72
		name.margin_top = 27
		name.margin_right = 180
		name.margin_bottom = 41
		name.rect_size.x = 108
		name.rect_position.x = 72
		
		var desc := Label.new()
		
		match x:
			0:
				desc.text = "Improves your mining\nlaser yield to 150."
			1:
				desc.text = "Improves your mining\nlaser yield to 300."
			2:
				desc.text = "Reduces your mining\nlaser cycle to 2.5,\nfor a yield of 200.\nDoubles the range."
			3:
				desc.text = "Reduces your mining\nlaser cycle to 2,\nfor a yield of 400."		
							
		desc.margin_left = 184
		desc.margin_top = 1
		desc.margin_right = 325
		desc.margin_bottom = 66
		desc.rect_size.x = 141
		desc.rect_position.x = 184
		
		var cost := Label.new()
		
		match x:
			0:
				cost.text = str(mining_laser_II_cost) + " credits"
			1:
				cost.text = str(mining_laser_III_cost) + " credits"
			2:
				cost.text = str(mining_laser_IV_cost) + " credits"
			3:
				cost.text = str(mining_laser_V_cost) + " credits"
		
		cost.margin_left = 329
		cost.margin_top = 27
		cost.margin_right = 417
		cost.margin_bottom = 41
		cost.rect_size.x = 88
		cost.rect_position.x = 329
		
		var buy_button := Button.new()
		buy_button.text = "BUY"				
		buy_button.align = Button.ALIGN_CENTER
		buy_button.margin_left = 421
		buy_button.margin_right = 459
		buy_button.margin_bottom = 68
		buy_button.rect_position.x = 421
		buy_button.rect_size.x = 38
		buy_button.rect_size.y = 68		
		
		# give the node a name index reachable. 10+X = mining laser X 20+X = cargoextender x (i.e. "102" > MiningLaserII; "204" > CargoExtIV")
		var button_id: int = 0
		match x:
			0:
				if (current_mining_laser == 2):
					# you can't buy your own mining laser
					buy_button.disabled = true
					
				button_id = 102
			1:
				if (current_mining_laser == 3):
					# you can't buy your own mining laser
					buy_button.disabled = true
				
				button_id = 103
			2:
				if (current_mining_laser == 4):
					# you can't buy your own mining laser
					buy_button.disabled = true
				
				button_id = 104
			3:
				if (current_mining_laser == 5):
					# you can't buy your own mining laser
					buy_button.disabled = true
				
				button_id = 105
				
		buy_button.connect("pressed", self, "_on_market_buy_selected", [button_id])		#signals the item selected		
		_market_ui_table.add_child(icon)
		_market_ui_table.add_child(name)
		_market_ui_table.add_child(desc)
		_market_ui_table.add_child(cost)
		_market_ui_table.add_child(buy_button)
		
func _on_market_buy_selected(index: int) -> void:
	match index:
		102:
			emit_signal("send_message", "You want to buy Mining Laser II!")			
		103:
			print("mining laser III clicked")
		104:
			print("mining laser IV clicked")
		105:
			print("mining laser V clicked")

func set_mode_cargo_extender() -> void:
	pass

func _on_CloseButton_pressed() -> void:
	hide()
