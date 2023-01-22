extends PopupDialog

# Emitted when the user presses the "apply" button.
signal yes_button_pressed()
signal no_button_pressed()

func set_message(title, message):
	$VBoxContainer/TITLELabel.text = title
	$VBoxContainer/MessageLabel.text = message

func _on_YesButton_pressed():
	emit_signal("yes_button_pressed")
	hide()

func _on_NoButton_pressed():
	emit_signal("no_button_pressed")
	hide()
