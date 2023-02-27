extends PopupDialog
onready var cargoand_refine: Label = $Panel/MarginContainer/VBoxContainer/CargoandRefine
onready var refine_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/RefineButton
onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CloseButton
onready var progress_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/ProgressBar

export var refining_time: float = 10

var cargo_hold: int = 0
var refining_fee: int = 0
var threshold: int = 0
var timer

signal refining_complete
signal send_message

func set_refine(fun_cargohold: int, fun_refining_fee: int, fun_threshold: int):
	self.cargo_hold = fun_cargohold
	self.refining_fee = fun_refining_fee
	self.threshold = fun_threshold
	progress_bar.value = 0
	
	var estimated_tritanium = self.cargo_hold / 5
	var fee = estimated_tritanium / 100 * self.refining_fee
	
	cargoand_refine.text = "  Cargo Hold: Veldspar " + str(cargo_hold) + " m3" + "\n" + "  Estimated Tritanium: " + str(estimated_tritanium) + " m3 (-" + str(fee) + " m3 refining fee)" + "\nRefining Threshold: " + str(self.threshold) + " m3\n\nRemainder ore will be destroyed in the process."
	
	# Create the timer
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(refining_time)
	timer.connect("timeout",self,"_on_refining_complete") 
	add_child(timer)

func _process(_delta: float) -> void:
	if timer == null:
		return
	elif timer.is_stopped() == false:
		#timer is running, update the progress bar
		progress_bar.value = (refining_time - timer.time_left) * 10

func refine() -> void:
	# check if there's enough ore for refine
	if (cargo_hold < threshold):
		print("You can't refine as you don't have enough ore.")
		emit_signal("send_message", "Not enough ore to refine.")
		return
		
	# If there are, disable buttons so the player can't be stupid
	refine_button.disabled = true
	close_button.disabled = true
	
	# start the progress bar with a timer
	timer.start()

func _on_refining_complete() -> void:
	# enable buttons again
	refine_button.disabled = false
	close_button.disabled = false	
	
	var estimated_tritanium = cargo_hold / 5
	var fee = estimated_tritanium / 100 * refining_fee
	
	var final_tritanium = estimated_tritanium - fee
	
	var final_ore = cargo_hold%5  
	
	# signal
	emit_signal("refining_complete", final_tritanium, final_ore)
		
	# close panel
	hide()

func _on_CloseButton_pressed() -> void:
	hide()

func _on_RefineButton_pressed() -> void:
	refine()
