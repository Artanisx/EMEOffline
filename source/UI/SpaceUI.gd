extends CanvasLayer

signal mining_button_pressed
signal overview_move_to
signal overview_warp_to
signal overview_dock_to
signal overview_mine_to
signal mining_cycle_completed

onready var _mining_cycle = $LowerHUD/MiningButton/MiningCycle
onready var _mining_bar = $LowerHUD/MiningButton/MiningBar
onready var moveto_button: TextureButton = $OverviewHUD/VBoxContainer/BUTTONSBOX/MOVETOButton
onready var warpto_button: TextureButton = $OverviewHUD/VBoxContainer/BUTTONSBOX/WARPTOButton
onready var dock: TextureButton = $OverviewHUD/VBoxContainer/BUTTONSBOX/DOCK
onready var mine: TextureButton = $OverviewHUD/VBoxContainer/BUTTONSBOX/MINE

func _process(delta) -> void:
	# MINING CYCLE TIMER
	if (_mining_cycle.is_stopped() != true):
		_mining_bar.value = _mining_bar.max_value - _mining_cycle.time_left	

func set_selection_buttons(movable: bool, warpable: bool, dockable: bool, minable: bool) -> void:
	moveto_button.disabled = !movable
	warpto_button.disabled = !warpable
	dock.disabled = !dockable
	mine.disabled = !minable			

func _on_MiningButton_pressed():
	emit_signal("mining_button_pressed")

func _on_MOVETOButton_pressed() -> void:
	emit_signal("overview_move_to")

func _on_WARPTOButton_pressed() -> void:
	emit_signal("overview_warp_to")

func _on_DOCK_pressed() -> void:
	emit_signal("overview_dock_to")
	
func _on_MINE_pressed() -> void:
	emit_signal("overview_mine_to")
	
func _on_MiningCycle_timeout() -> void:
	emit_signal("mining_cycle_completed")
