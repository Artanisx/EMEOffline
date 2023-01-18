extends ColorRect

onready var _transition_rect := $SceneTransiction
onready var _message_box := $MessageBox

const SAVE_VAR := "user://users.sav"

var save_exists = false

func _ready():
	## check if a save exists
	
	#Open a file
	var file := File.new()	
	
	var error := file.open_encrypted_with_pass (SAVE_VAR, File.READ, "emeOfflineSaves")
	
	if error == OK:
		## We have a save file. This means there are players in here.
		## We should provide an autocomplete or hint to the account names here
		## For now, we just say "STATUS: READY"		
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.text = "STATUS: READY"
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.add_color_override("font_color", Color(0,0,0))
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.hint_tooltip = "There are character(s) saved."
		$MarginContainer/VBoxContainer/FOOTER3/CONNECTButton2.text = "CONNECT"
		save_exists = true
	else:
		## No save present. Let's put some text in the status
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.text = "STATUS: NOT READY"
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.add_color_override("font_color", Color(1,0,0))			
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.hint_tooltip =  "There is no character saved. Create a new one."
		$MarginContainer/VBoxContainer/FOOTER3/CONNECTButton2.text = "CREATE"
		save_exists = false

func _on_QUITButton_button_up():
	get_tree().quit()

func _on_CONNECTButton2_button_up():
	if $MarginContainer/VBoxContainer/FOOTER/UsernameLineEdit.text == "":
		show_message_box("LOGGING IN", "Insert a username!", true)	
		pass # Show a messagebox telling the player they need to put a username
	else:
		if save_exists:
			show_message_box("LOGGING IN", "OK save exists, I should check if the username is in the save!", true)				
			#Globals.set_loaded_true()
			#_transition_rect.transition_to("res://src/Main/Main.tscn")	
			pass #check if username is in the savefile, if yes > load. if not > messagebox
		else:
			show_message_box("LOGGING IN", "No save exists, so we should create an empty one and save this account!", true)			
			#_transition_rect.transition_to("res://src/Main/Main.tscn")
			pass #since there's no savegame, create a empty save with this account

func _on_SETTINGSButton_button_up():
	show_message_box("SETTINGS", "There are no settings for now, but soon there will be.", true)	
	
func show_message_box(title, message, centered):
	_message_box.set_message(title, message)
	if centered:
		_message_box.popup_centered()
	else:
		_message_box.popup()
	
