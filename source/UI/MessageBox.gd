extends PopupDialog

func set_message(title, message):
	$VBoxContainer/TITLELabel.text = title
	$VBoxContainer/MessageLabel.text = message

func _on_OKButton_button_up():
	hide()
