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
onready var midhud: Panel = $MIDHUD
onready var message: Label = $MIDHUD/MESSAGE
onready var _mid_animation_player: AnimationPlayer = $MIDHUD/AnimationPlayer
onready var right_arrow: TextureRect = $OverviewHUD/RightArrow


func _process(_delta) -> void:
	# MINING CYCLE TIMER
	if (_mining_cycle.is_stopped() != true):
		_mining_bar.value = _mining_bar.max_value - _mining_cycle.time_left	

func show_arrow(step: int) -> void:
	match step:
		1: 
			#Overview
			right_arrow.rect_rotation = 0
			right_arrow.rect_position = Vector2(-76, 114)
			right_arrow.visible = true
		2:
			#Selectio nscreen
			right_arrow.rect_rotation = 0
			right_arrow.rect_position = Vector2(-117, 40)
			right_arrow.visible = true
		3:
			#Move To Button
			right_arrow.rect_rotation = 0
			right_arrow.rect_position = Vector2(-6, 72)
			right_arrow.visible = true
		4:
			#Warp To Button
			right_arrow.rect_rotation = 0
			right_arrow.rect_position = Vector2(37, 72)
			right_arrow.visible = true	
		5:
			#Dock To Button
			right_arrow.rect_rotation = 0
			right_arrow.rect_position = Vector2(70, 72)
			right_arrow.visible = true	
		6:
			#Mine To Button
			right_arrow.rect_rotation = 0
			right_arrow.rect_position = Vector2(103, 72)
			right_arrow.visible = true	
		7:
			#LOW HUD
			right_arrow.rect_rotation = 90
			right_arrow.rect_position = Vector2(-353, 497)
			right_arrow.visible = true	
		8:
			#RED BAR
			right_arrow.rect_rotation = 90
			right_arrow.rect_position = Vector2(-454, 584)
			right_arrow.visible = true	
		9:
			#GREEN BAR
			right_arrow.rect_rotation = 90
			right_arrow.rect_position = Vector2(-352, 593)
			right_arrow.visible = true	
		10:
			#YELLOW BAR
			right_arrow.rect_rotation = 90
			right_arrow.rect_position = Vector2(-260, 584)
			right_arrow.visible = true	
		11:
			#MINING BUTTON
			right_arrow.rect_rotation = 90
			right_arrow.rect_position = Vector2(-161, 535)
			right_arrow.visible = true	
		_:
			right_arrow.visible = false		
	

func set_selection_buttons(movable: bool, warpable: bool, dockable: bool, minable: bool) -> void:
	moveto_button.disabled = !movable
	warpto_button.disabled = !warpable
	dock.disabled = !dockable
	mine.disabled = !minable			

func show_mid_message(message_to_show: String) -> void:
	message.text = message_to_show	
	_mid_animation_player.play("FadeIn")
	
func fade_out_message() -> void:
	_mid_animation_player.play("FadeOut")

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
