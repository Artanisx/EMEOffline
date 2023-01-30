extends CanvasLayer

signal mining_button_pressed
signal overview_name1_selected
signal overview_name2_selected
signal overview_name3_selected
signal overview_name4_selected
signal overview_name5_selected
signal overview_name6_selected
signal overview_name7_selected
signal overview_move_to
signal mining_cycle_completed

onready var _mining_cycle = $LowerHUD/MiningButton/MiningCycle
onready var _mining_bar = $LowerHUD/MiningButton/MiningBar

func _process(delta) -> void:
	# MINING CYCLE TIMER
	if (_mining_cycle.is_stopped() != true):
		_mining_bar.value = _mining_bar.max_value - _mining_cycle.time_left	
		

func _on_MiningButton_pressed():
	emit_signal("mining_button_pressed")

func _on_NAME1_gui_input(event: InputEvent) -> void:	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:            
			emit_signal("overview_name1_selected")

func _on_NAME2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:            
			emit_signal("overview_name2_selected")


func _on_NAME3_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:            
			emit_signal("overview_name3_selected")


func _on_NAME4_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:            
			emit_signal("overview_name4_selected")


func _on_NAME5_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:            
			emit_signal("overview_name5_selected")


func _on_NAME6_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:            
			emit_signal("overview_name6_selected")


func _on_NAME7_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:            
			emit_signal("overview_name7_selected")			

func _on_MOVETOButton_pressed() -> void:
	emit_signal("overview_move_to")

func _on_MiningCycle_timeout() -> void:
	emit_signal("mining_cycle_completed")
