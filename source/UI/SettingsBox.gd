# User interface that allows the player to select game settings.
# To see how we update the actual window and rendering settings, see
# `Main.gd`.
extends Control

# Emitted when the user presses the "apply" button.
signal apply_button_pressed(settings)

# We store the selected settings in a dictionary
var _settings := {resolution = Vector2(1280, 720), fullscreen = OS.window_fullscreen, vsync = OS.vsync_enabled}

func refresh() -> void:
	$VBoxContainer/UIVsyncCheckbox/VSyncCheckBox.pressed = OS.vsync_enabled
	$VBoxContainer/UIFullScreenCheckbox/FullScreenCheckBox.pressed = OS.window_fullscreen

# Emit the `apply_button_pressed` signal, when user presses the button.
func _on_ApplyButton_pressed() -> void:
	# Send the last selected settings with the signal
	emit_signal("apply_button_pressed", _settings)

# Store the resolution selected by the user. As this function is connected
# to the `resolution_changed` signal, this will be executed any time the
# users chooses a new resolution
func _on_UIResolutionSelector_resolution_changed(new_resolution: Vector2) -> void:
	_settings.resolution = new_resolution
	print("resolution changed: ")
	print(new_resolution)

# Store the fullscreen setting. This will be called any time the users toggles
# the UIFullScreenCheckbox
func _on_FullScreenCheckBox_toggled(button_pressed):
	_settings.fullscreen = button_pressed
	print("full screen changed: ")
	print(button_pressed)
	
# Store the vsync seting. This will be called any time the users toggles
# the UIVSyncCheckbox
func _on_VSyncCheckBox_toggled(button_pressed):
	_settings.vsync = button_pressed
	print("vsync changed: ")
	print(button_pressed)






