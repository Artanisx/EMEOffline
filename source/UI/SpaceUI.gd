extends CanvasLayer

signal mining_button_pressed

onready var _mining_cycle = $LowerHUD/MiningButton/MiningCycle
onready var _mining_bar = $LowerHUD/MiningButton/MiningBar

var mining_button_hover: bool = false

func _process(delta) -> void:
	# MINING CYCLE TIMER
	if (_mining_cycle.is_stopped() != true):
		_mining_bar.value = _mining_bar.max_value - _mining_cycle.time_left	

func _on_MiningButton_mouse_entered():
	mining_button_hover = true

func _on_MiningButton_mouse_exited():
	mining_button_hover = false

func _on_MiningButton_pressed():
	emit_signal("mining_button_pressed")
