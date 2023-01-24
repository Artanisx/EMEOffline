extends ColorRect

onready var _transition_rect := $SceneTransition
onready var _message_box := $MessageBox
onready var _question_box := $QuestionBox
onready var _settings_box := $SettingsPanel
onready var _audio_aura_connecting := $AURA_Connecting
onready var _audio_aura_request_denied := $AURA_RequestDenied

# SAVE path "C:\Users\Fabrizio\AppData\Roaming\Godot\app_userdata\EME Offline"

var save_exists = false
var valid_saves = []
var screen_size = OS.get_screen_size(0)
var window_size = OS.get_window_size()

func load_savegames() -> void:
	#First, I need to check if there are any .sav files in the user:// folder
	
	# Initialize a variable to track if any ".sav" files are found
	var sav_found = false
	
	# Initalize the valid saves variable
	valid_saves = []
	
	# Initiale a charater name array
	var valid_names = []
	
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
				valid_names.append(file_name.get_basename())	
			file_name = dir.get_next()
	else:
		print("no files found or error accessing user://")	

	if sav_found:
		print("saves found:")		
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.text = "STATUS: READY"
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.add_color_override("font_color", Color(1,1,1))
		$MarginContainer/VBoxContainer/FOOTER2/StatusLabel.hint_tooltip = "Available character(s):"+str(valid_names)
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


func create_new_save() -> void:
	show_question_box("CREATING USER", "This account doesn't exists. Do you want to create it?", true, "_on_QB_create_yes", "_on_QB_create_no")
	
func show_question_box(title, message, centered, callback_yes, callback_no) -> void:
	# Clear the QuestionBox singla connections first	
	_question_box.clear_connections()
	
	# Connect the signals to the specified callbacks
	_question_box.connect("yes_button_pressed", self, callback_yes)	
	_question_box.connect("no_button_pressed", self, callback_no)	
	
	# Show the question box
	_question_box.set_message(title, message)
	if centered:
		_question_box.popup_centered()
	else:
		_question_box.popup()
	
func show_message_box(title, message, centered):
	_message_box.set_message(title, message)
	if centered:
		_message_box.popup_centered()
	else:
		_message_box.popup()
	
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

func load_save(username: String) -> bool:	
	# Make sure it's all lowercase
	username = username.to_lower()
	
	# add the extension
	username += ".sav"
	
	print(username)
	
	#Open a file
	var file := File.new()
	var err := file.open_encrypted_with_pass ("user://"+username, File.READ, "emeOfflineSaves")
	
	if err != OK:		
		print("Error loading a new save.")		
		return false	
	
	# A savegame has this structure
	# #########
	# CREDITS: 0-999999			## How many credits are there
	# MININGLASER: 1-5			## What is the Mining Laser installed, from 1 to 5
	# CARGOHOLDEXT: 0-5			## What is the cargo Extender upgrade installed, from 0 to 5.
	# CARGOVELDSPAR: 0-99999	## How much veldspar is in the cargo hold, if any
	# POSITION: (0,0)			## The last position. It should be nearby the station at the beginning of the game.
	# #########
	
	Globals.set_loaded_user(
		int(str2var(file.get_line())),
		int(str2var(file.get_line())),
		int(str2var(file.get_line())),
		int(str2var(file.get_line())),
		StringHelper.string_to_vector2(str2var(file.get_line())))
		
	Globals.set_loaded_true()
		
	print("loaded save")	
	return true

func new_save(username: String) -> bool:
	# Make sure it's all lowercase
	username = username.to_lower()
	
	# add the extension
	username += ".sav"
	
	print(username)
	
	#Open a file
	var file := File.new()
	var err := file.open_encrypted_with_pass ("user://"+username, File.WRITE, "emeOfflineSaves")
	
	if err != OK:		
		print("Error creating a new save.")
		return false
	
	# Create an empty savegame
	# A savegame has this structure
	# #########
	# CREDITS: 0-999999			## How many credits are there
	# MININGLASER: 1-5			## What is the Mining Laser installed, from 1 to 5
	# CARGOHOLDEXT: 0-5			## What is the cargo Extender upgrade installed, from 0 to 5.
	# CARGOVELDSPAR: 0-99999	## How much veldspar is in the cargo hold, if any
	# POSITION: (0,0)			## The last position. It should be nearby the station at the beginning of the game.
	# #########
	
	file.store_line("0")		# Credits
	file.store_line("1")		# Mining Laser I
	file.store_line("0")		# No Cargo Extender
	file.store_line("0")		# Cargo hold empty
	file.store_line("(0,0)")	# Starting position
	
	print("saved file:")	
	print(username)	
	
	# Set these values in the globals
	Globals.set_loaded_true()
	Globals.set_loaded_user(0,1,0,0,Vector2.ZERO)
	
	# This message box should probably go away
	show_message_box("ACCOUNT CREATION", "Account " + username + " created", true)
	return true

func clear_all_saves():
	# Clear all saved games (madness!)
	var ext: String = "sav"
	var dir = Directory.new()
	dir.open("user://")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":					
			break
		elif not file.begins_with(".") and file.right((file.length()-ext.length())) == ext:
			dir.remove(file)
	dir.list_dir_end()
	show_message_box("SAVES CLEARED", "All saved accounts have been cleared. They can't be recovered now.", true)		

# CALLBACKS
func _on_INFOButton_pressed():
	show_message_box("AURA", "Welcome to EME Offline, capsuler. This is a very small fan game set in the EVE Online world. The idea is to have fun alone, without other players! Only a extremely small subset of mechanics and locations are present, but it might be just the beginning...", true)		

func _on_SettingsPanel_apply_button_pressed(settings):
	# Update the game settings
	update_settings(settings)
	
	# Finally, hide the settings panel
	_settings_box.visible = false	
	
# Callbacks for QuestionBox: Create new user - REPLY YES
func _on_QB_create_yes():
	print("Create YES!")	
	var username = $MarginContainer/VBoxContainer/FOOTER/UsernameLineEdit.text
	var created = new_save(username)	
	if (created == true):
		print("So, I have these values in globals. Creds:" + str(Globals.get_account_credits()) 
						+ " MiningLaser: " + str(Globals.get_account_mininglaser()) 
						+ " Cargo Extender: " + str(Globals.get_account_cargoextender()) 
						+ " Cargo Hold: " + str(Globals.get_account_cargohold()) 
						+ " and position: " + str(Globals.get_account_position()))
		print("Game should now load...")
		# SOUND: AURA - "CONNECTING..."
		_audio_aura_connecting.play()		
		$MarginContainer/VBoxContainer/FOOTER3/CONNECTButton2.text = "CONNECTING..."
		pass # now that the account is created the game should load.		
	else:
		show_message_box("ERROR", "Error creating a new account!", true)
		_audio_aura_request_denied.play()

# Callbacks for QuestionBox: Create new user - REPLY NO
func _on_QB_create_no():
	print("Create NO!")
	
# Callbacks for QuestionBox: Clear all saves - REPLY YES
func _on_QB_clear_yes():
	print("Clear all saves yes")
	clear_all_saves()
	
# Callbacks for QuestionBox: Clear all saves - REPLY NO
func _on_QB_clear_no():
	print("Clear all saves no")
	
func _on_SETTINGSButton_button_up():
	_settings_box.refresh()
	_settings_box.visible = true	
	
func _on_QUITButton_button_up():
	get_tree().quit()

func _on_CONNECTButton2_button_up():
	# Load saves
	load_savegames()
	
	var correct_save_found = false
	var username = $MarginContainer/VBoxContainer/FOOTER/UsernameLineEdit.text
	
	# Make username lowercase so we don't have issues with casing
	username = username.to_lower()
	print(username)
	if username == "":
		show_message_box("LOGIN FAILED", "Insert a username!", true)
		_audio_aura_request_denied.play()
		return		
	elif username == "clear":
		show_question_box("CLEAR ALL SAVES", "Are you sure you want to clear all saved accounts?", true, "_on_QB_clear_yes", "_on_QB_clear_no")
		return
	elif "remove*" in username:		
		var username_to_remove: String = username.get_slice("*",1)
		username_to_remove += ".sav"
		var dir = Directory.new()
		dir.open("user://")
		var err = dir.remove(username_to_remove)		
		if err != OK:
			show_message_box("ERROR", "Error while trying to erase account.", true)
			_audio_aura_request_denied.play()
			return
		else:
			show_message_box("ACCOUNT REMOVED", "Account " + username_to_remove.get_basename() + " removed.", true)
		return
	else:
		if save_exists:
			print(valid_saves)
			for name in valid_saves:
				print(name)
				if name.get_basename() == username:
					print("User found in save!")
					correct_save_found = true
					break			
			
			if correct_save_found:
				# We have found the correct save, we now need to LOAD PLAYER VALUES!
				print ("LOADING USER as this was found")
				if load_save(username):
					print("So, I have these values in globals. Creds:" + str(Globals.get_account_credits()) 
						+ " MiningLaser: " + str(Globals.get_account_mininglaser()) 
						+ " Cargo Extender: " + str(Globals.get_account_cargoextender()) 
						+ " Cargo Hold: " + str(Globals.get_account_cargohold()) 
						+ " and position: " + str(Globals.get_account_position()))
				# Game should now load
				# SOUND: AURA - "CONNECTING..."
				_audio_aura_connecting.play()
				$MarginContainer/VBoxContainer/FOOTER3/CONNECTButton2.text = "CONNECTING..."
				#_transition_rect.transition_to("res://src/Main/Main.tscn")	
				pass
			else:
				# Check if we haven't found a correct save after all...		
				# Since this user doens't exist, we'll prompt creation of the account
				create_new_save()
				print("CREATING USER as this is not a known username!")				
		else:
			# This should happen if there are no user saves!
			create_new_save()
			print("CREATING USER as No save exists!")
			#_transition_rect.transition_to("res://src/Main/Main.tscn")
			pass #since there's no savegame, create a empty save with this account
