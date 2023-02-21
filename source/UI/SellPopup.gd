extends PopupDialog
onready var sell_stats: Label = $Panel/MarginContainer/VBoxContainer/SellStats
onready var sell_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/SellButton
onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CloseButton

var current_trit: int = 0
var sale_fee: int = 0
var threshold: int = 0
var ask_per_threshold: int = 0

signal sale_complete

func set_sale(current_tritanium: int, sale_fee: int, sale_threshold: int, ask_x_threshold: int):	
	self.current_trit = current_tritanium
	self.sale_fee = sale_fee
	self.threshold = sale_threshold
	self.ask_per_threshold = ask_x_threshold
	
	var estimated_sale = (self.current_trit / self.threshold) * self.ask_per_threshold 
	var fee = estimated_sale / 100 * self.sale_fee
	
	sell_stats.text = "  Current Tritanium Prices: " + str(self.ask_per_threshold) + " ASK per " + str(self.threshold) + " m3\n  Station Tritanium: " + str(self.current_trit) + " m3\n  Estimated Sell Order Profit: " + str(estimated_sale) + " ASK (-" + str(fee) + " ASK Station Sale Fee)"	

func sell() -> void:
	var estimated_sale = (self.current_trit / self.threshold) * self.ask_per_threshold
	var fee = estimated_sale / 100 * self.sale_fee
	
	var final_sale = estimated_sale - fee
	var final_trit = 0
		
	# signal
	emit_signal("sale_complete", final_sale, final_trit)
		
	# close panel
	hide()

func _on_SellButton_pressed() -> void:
	sell()

func _on_CloseButton_pressed() -> void:
	hide()
