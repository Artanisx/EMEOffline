extends PopupDialog

onready var _market_logo: TextureRect = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MarketLogo
onready var _market_title: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MarketTitle
onready var _market_ui_table: GridContainer = $Panel/MarginContainer/VBoxContainer/GridContainer

var mining_laser_II_icon = load("res://assets/art/ui/station_icon_mininglaserII.png")	
var mining_laser_III_icon = load("res://assets/art/ui/station_icon_mininglaserIII.png")
var mining_laser_IV_icon = load("res://assets/art/ui/station_icon_mininglaserIV.png")
var mining_laser_V_icon = load("res://assets/art/ui/station_icon_mininglaserV.png")
var cargo_ext_I_icon = load("res://assets/art/ui/station_icon_cargo_expanderI.png")
var cargo_ext_II_icon = load("res://assets/art/ui/station_icon_cargo_expanderII.png")
var cargo_ext_III_icon = load("res://assets/art/ui/station_icon_cargo_expanderIII.png")
var cargo_ext_IV_icon = load("res://assets/art/ui/station_icon_cargo_expanderIV.png")
var cargo_ext_V_icon = load("res://assets/art/ui/station_icon_cargo_expanderV.png")

var market_mode: String = ""
var current_credits: int = 0
var current_mining_laser: int = 1
var current_cargo_expander: int = 0

const mining_laser_II_cost = 60000
const mining_laser_III_cost = 90000
const mining_laser_IV_cost = 180000
const mining_laser_V_cost = 250000

const cargo_ext_I_cost = 5000
const cargo_ext_II_cost = 15000
const cargo_ext_III_cost = 35000
const cargo_ext_IV_cost = 800000
const cargo_ext_V_cost = 200000

signal mining_laser_upgrade_complete
signal cargo_extender_upgrade_complete
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
	elif(market_mode == "CargoExtender"):
		set_mode_cargo_extender()

func set_mode_mining_laser() -> void:
	# For mining lasers we have 4, from Mining Laser II to Mining Laser V so we need 4 rows
	for x in 4:
		var icon := TextureRect.new()	
		
		match x:
			0:
				icon.texture = mining_laser_II_icon
			1:
				icon.texture = mining_laser_III_icon
			2:
				icon.texture = mining_laser_IV_icon
			3: 
				icon.texture = mining_laser_V_icon
		
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
		
func set_mode_cargo_extender() -> void:
	# For cargo extender we have 5, from Cargo Extender I to Cargo Extender V so we need 5 rows
	for x in 5:
		var icon := TextureRect.new()	
		
		match x:
			0:
				icon.texture = cargo_ext_I_icon
			1:
				icon.texture = cargo_ext_II_icon
			2:
				icon.texture = cargo_ext_III_icon
			3: 
				icon.texture = cargo_ext_IV_icon
			4: 
				icon.texture = cargo_ext_V_icon
		
		icon.margin_right = 68
		icon.margin_bottom = 68			
		icon.rect_size.x = 68
		icon.rect_size.y = 68		
		
		var name := Label.new()
		
		match x:
			0:
				name.text = "CARGO EXTENDER I"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_cargo_expander == 1):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
			1:
				name.text = "CARGO EXTENDER II"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_cargo_expander == 2):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
			2:
				name.text = "CARGO EXTENDER III"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_cargo_expander == 3):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
			3:
				name.text = "CARGO EXTENDER IV"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_cargo_expander == 4):
					name.set("custom_colors/font_color", Color(1,0,0))
				else:
					name.set("custom_colors/font_color", Color(1,1,1))					
			4:
				name.text = "CARGO EXTENDER V"
				
				#Color this in red if it's the current upgrade, white otherwise
				if (current_cargo_expander == 5):
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
				desc.text = "Expand your cargo\nhold capacity by 1000."
			1:
				desc.text = "Expand your cargo\nhold capacity by 2000."
			2:
				desc.text = "Expand your cargo\nhold capacity by 4000."
			3:
				desc.text = "Expand your cargo\nhold capacity by 6000."
			4:
				desc.text = "Expand your cargo\nhold capacity by 9000."
							
		desc.margin_left = 184
		desc.margin_top = 1
		desc.margin_right = 325
		desc.margin_bottom = 66
		desc.rect_size.x = 141
		desc.rect_position.x = 184
		
		var cost := Label.new()
		
		match x:
			0:
				cost.text = str(cargo_ext_I_cost) + " ASK"
			1:
				cost.text = str(cargo_ext_II_cost) + " ASK"
			2:
				cost.text = str(cargo_ext_III_cost) + " ASK"
			3:
				cost.text = str(cargo_ext_IV_cost) + " ASK"
			4:
				cost.text = str(cargo_ext_V_cost) + " ASK"
		
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
				if (current_cargo_expander == 1):
					# you can't buy your own cargo expander
					buy_button.disabled = true
					
				button_id = 201
			1:
				if (current_cargo_expander == 2):
					# you can't buy your own cargo expander
					buy_button.disabled = true
				
				button_id = 202
			2:
				if (current_cargo_expander == 3):
					# you can't buy your own cargo expander
					buy_button.disabled = true
				
				button_id = 203
			3:
				if (current_cargo_expander == 4):
					# you can't buy your own cargo expander
					buy_button.disabled = true
				
				button_id = 204
			4:
				if (current_cargo_expander == 5):
					# you can't buy your own cargo expander
					buy_button.disabled = true
				
				button_id = 205
				
		buy_button.connect("pressed", self, "_on_market_buy_selected", [button_id])		#signals the item selected		
		_market_ui_table.add_child(icon)
		_market_ui_table.add_child(name)
		_market_ui_table.add_child(desc)
		_market_ui_table.add_child(cost)
		_market_ui_table.add_child(buy_button)
		
func _on_market_buy_selected(index: int) -> void:
	match index:
		102:			
			buy_mining_laser(2)		
		103:
			buy_mining_laser(3)
		104:
			buy_mining_laser(4)
		105:
			buy_mining_laser(5)
		201:
			buy_cargo_extender(1)
		202:
			buy_cargo_extender(2)
		203:
			buy_cargo_extender(3)
		204:
			buy_cargo_extender(4)
		205:
			buy_cargo_extender(5)

func buy_mining_laser(mining_laser: int) -> void:
	if (current_mining_laser >= mining_laser):
		# user is trying to downgrade or buy the same
		emit_signal("send_message", "You can't buy that!")
		return
	
	match mining_laser:
		2:
			if (current_credits < mining_laser_II_cost):
				emit_signal("send_message", "Not enough credits!")
				return
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - mining_laser_II_cost
				
				# Upgrade the mining laser accordingly
				current_mining_laser = 2
				
				# Send signal
				emit_signal("mining_laser_upgrade_complete", current_mining_laser, current_credits)
				
				# close panel
				hide()
		3:
			if (current_credits < mining_laser_III_cost):
				emit_signal("send_message", "Not enough credits!")
				return
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - mining_laser_III_cost
				
				# Upgrade the mining laser accordingly
				current_mining_laser = 3
				
				# Send signal
				emit_signal("mining_laser_upgrade_complete", current_mining_laser, current_credits)
				
				# close panel
				hide()
		4:
			if (current_credits < mining_laser_IV_cost):
				emit_signal("send_message", "Not enough credits!")
				return
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - mining_laser_IV_cost
				
				# Upgrade the mining laser accordingly
				current_mining_laser = 4
				
				# Send signal
				emit_signal("mining_laser_upgrade_complete", current_mining_laser, current_credits)
				
				# close panel
				hide()
		5:
			if (current_credits < mining_laser_V_cost):
				emit_signal("send_message", "Not enough credits!")
				return	
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - mining_laser_V_cost
				
				# Upgrade the mining laser accordingly
				current_mining_laser = 5
				
				# Send signal
				emit_signal("mining_laser_upgrade_complete", current_mining_laser, current_credits)
				
				# close panel
				hide()		

func buy_cargo_extender(cargo_extender: int) -> void:
	if (current_cargo_expander >= cargo_extender):
		# user is trying to downgrade or buy the same
		emit_signal("send_message", "You can't buy that!")
		return
	
	match cargo_extender:
		1:
			if (current_credits < cargo_ext_I_cost):
				emit_signal("send_message", "Not enough credits!")
				return
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - cargo_ext_I_cost
				
				# Upgrade the cargo extender accordingly
				current_cargo_expander = 1
				
				# Send signal
				emit_signal("cargo_extender_upgrade_complete", current_cargo_expander, current_credits)
				
				# close panel
				hide()
		2:
			if (current_credits < cargo_ext_II_cost):
				emit_signal("send_message", "Not enough credits!")
				return
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - cargo_ext_II_cost
				
				# Upgrade the cargo extender accordingly
				current_cargo_expander = 2
				
				# Send signal
				emit_signal("cargo_extender_upgrade_complete", current_cargo_expander, current_credits)
				
				# close panel
				hide()
		3:
			if (current_credits < cargo_ext_III_cost):
				emit_signal("send_message", "Not enough credits!")
				return
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - cargo_ext_III_cost
				
				# Upgrade the cargo extender accordingly
				current_cargo_expander = 3
				
				# Send signal
				emit_signal("cargo_extender_upgrade_complete", current_cargo_expander, current_credits)
				
				# close panel
				hide()
		4:
			if (current_credits < cargo_ext_IV_cost):
				emit_signal("send_message", "Not enough credits!")
				return
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - cargo_ext_IV_cost
				
				# Upgrade the cargo extender accordingly
				current_cargo_expander = 4
				
				# Send signal
				emit_signal("cargo_extender_upgrade_complete", current_cargo_expander, current_credits)
				
				# close panel
				hide()
		5:
			if (current_credits < cargo_ext_V_cost):
				emit_signal("send_message", "Not enough credits!")
				return	
			else:
				# Subtracts credits for the buy
				current_credits = current_credits - cargo_ext_V_cost
				
				# Upgrade the cargo extender accordingly
				current_cargo_expander = 5
				
				# Send signal
				emit_signal("cargo_extender_upgrade_complete", current_cargo_expander, current_credits)
				
				# close panel
				hide()	

func _on_CloseButton_pressed() -> void:
	hide()
