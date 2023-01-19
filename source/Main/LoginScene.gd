extends ColorRect

onready var _transition_rect := $SceneTransition
onready var _message_box := $MessageBox
onready var _settings_box := $SettingsPanel

const SAVE_VAR := "user://users.sav"

var save_exists = false
var valid_saves = []
var screen_size = OS.get_screen_size(0)
var window_size = OS.get_window_size()

func load_savegames() -> void:
	#First, I need to check if there are any .sav files in the user:// folder
	
	# Initialize a variable to track if any ".sav" files are found
	var sav_found = false
	
	# Create a new Directory object
	var dir = Directory.new()
	
	if dir.open("user://") == OK:		
		# Get a list of all files in the current directory	
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".sav"):
				sav_found = true
				valid_saves.append(file_name.to_lower())				
			file_name = dir.get_next()
	else:
		print("no files found or error accessing user://")	

	if sav_found:
		print("saves found:")		
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.text = "STATUS: READY"
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.add_color_override("font_color", Color(1,1,1))
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.hint_tooltip = "There are character(s) saved."
		$MarginContainer/VBoxContainer/FOOTER3/CONNECTButton2.text = "CONNECT"
		save_exists = true
	else:
		print("saves not found")
		## No save present. Let's put some text in the status
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.text = "STATUS: NOT READY"
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.add_color_override("font_color", Color(1,0,0))			
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.hint_tooltip =  "There is no character saved. Create a new one."
		$MarginContainer/VBoxContainer/FOOTER3/CONNECTButton2.text = "CREATE"
		save_exists = false
	
	
	#Open a file
	#var file := File.new()
	#var exist = file.file_exists(PATH_2_FILE):	
	#var error := file.open_encrypted_with_pass (SAVE_VAR, File.READ, "emeOfflineSaves")
	#Open a file
	#var file := File.new()	
	#var error := file.open_encrypted_with_pass (SAVE_VAR, File.READ, "emeOfflineSaves")
	
func _input(event):
	# Make sure the CONNECT button is focused if you press ENTER so logging in is quick
	if (event.is_action_pressed("ui_accept")):
		if not _message_box.visible and not _settings_box.visible:
			$MarginContainer/VBoxContainer/FOOTER3/CONNECTButton2.grab_focus()			

func _ready():	
	# Make sure the window is centered, unless fullscreen
	if OS.window_fullscreen == false:
		OS.set_window_position(screen_size*0.5 - window_size*0.5)
		
	# Load Settings if they exists
	load_settings()
	
	## Check if there are savegames
	load_savegames()
	
	# Give focus to the username filed
	$MarginContainer/VBoxContainer/FOOTER/UsernameLineEdit.grab_focus()	

func _on_QUITButton_button_up():
	get_tree().quit()

func _on_CONNECTButton2_button_up():
	var correct_save_found = false
	var username = $MarginContainer/VBoxContainer/FOOTER/UsernameLineEdit.text
	username.to_lower()
	print(username)
	if username == "":
		show_message_box("LOGIN FAILED", "Insert a username!", true)	
		pass # Show a messagebox telling the player they need to put a username
	else:
		if save_exists:
			print(valid_saves)
			for name in valid_saves:
				print(name)
				if name.get_basename() == username:
					print("User found in save!")
					correct_save_found = true
					break
			# We have found the corret save, we now need to LOAD PLAYER VALUES!
			#Globals.set_loaded_true()
			#_transition_rect.transition_to("res://src/Main/Main.tscn")	
						
			# Check if we haven't found a correct save after all...		
			if correct_save_found == false:
				show_message_box("LOGIN FAILED", "Username not found!", true)
		else:
			show_message_box("CREATING USER", "No save exists, so we should create an empty one and save this account!", true)		
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


func _on_INFOButton_pressed():
	show_message_box("AURA", "Welcome to EME Offline, capsuler. This is a very small fan game set in the EVE Online world. The idea is to have fun alone, without other players! Only a extremely small subset of mechanics and locations are present, but it might be just the beginning...", true)		
