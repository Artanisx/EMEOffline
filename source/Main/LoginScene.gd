extends ColorRect

onready var _transition_rect := $SceneTransition
onready var _message_box := $MessageBox
onready var _settings_box := $SettingsPanel

const SAVE_VAR := "user://users.sav"

var save_exists = false
var screen_size = OS.get_screen_size(0)
var window_size = OS.get_window_size()

func _ready():
	# Make sure the window is centered, unless fullscreen
	if OS.window_fullscreen == false:
		OS.set_window_position(screen_size*0.5 - window_size*0.5)
		
	# Load Settings if they exists
	load_settings()
	
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
	_settings_box.refresh()
	_settings_box.visible = true	
	
func show_message_box(title, message, centered):
	_message_box.set_message(title, message)
	if centered:
		_message_box.popup_centered()
	else:
		_message_box.popup()

func _on_SettingsPanel_apply_button_pressed(settings):
	# Update the game settings
	update_settings(settings)
	
	# Finally, hide the settings panel
	_settings_box.visible = false	
	
# We use a dictionary to represent settings because we have few values for now. Also, when you
# have many more settings, you can replace it with an object without having to refactor the code
# too much, as in GDScript, you can access a dictionary's keys like you would access an object's
# member variables.
func update_settings(settings: Dictionary) -> void:
	OS.window_fullscreen = settings.fullscreen	
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, settings.resolution
	)
	OS.set_window_size(settings.resolution)
	OS.vsync_enabled = settings.vsync
	
	# Save settings in the settings file
	var config = ConfigFile.new()
	
	config.set_value("Settings", "Game_Resolution", settings.resolution)
	config.set_value("Settings", "Game_FullScreen", settings.fullscreen)
	config.set_value("Settings", "Game_VSync", settings.vsync)
	
	# Save it to a file (overwrite if already exists).
	config.save("user://settings.cfg")
	
func load_settings() -> void:	
	var config = ConfigFile.new()
	
	# Load configs from dfile
	var err = config.load("user://settings.cfg")
	
	# if the file didn't load, it doesn't exists so ignore it
	if err != OK:
		print("Settings not loaded!")
		return
	
	# If it DOES exist load and set	
	var setting_resolution = config.get_value("Settings", "Game_Resolution")
	var setting_fullscreen = config.get_value("Settings", "Game_FullScreen")
	var setting_vsync = config.get_value("Settings", "Game_VSync")
	
	print("I've loaded the settings. Resolution is ")	
	print(setting_resolution)
	
	print("FullScreen is ")	
	print(setting_fullscreen)
	
	print("VSync is ")	
	print(setting_vsync)
	
	# Create a dictionary with the settings
	var setting_dict := {resolution = setting_resolution, fullscreen = setting_fullscreen, vsync = setting_vsync}
		
	# apply settings
	update_settings(setting_dict)
