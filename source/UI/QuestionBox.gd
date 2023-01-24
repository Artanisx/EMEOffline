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
	
func clear_connections():
	var signals = self.get_signal_list()
	
	for cur_signal in signals:
		var connections = self.get_signal_connection_list("yes_button_pressed")
		for cur_conn in connections:
			self.disconnect("yes_button_pressed", cur_conn.target, cur_conn.method)
		
		connections = self.get_signal_connection_list("no_button_pressed")
		for cur_conn in connections:
			self.disconnect("no_button_pressed", cur_conn.target, cur_conn.method)		
