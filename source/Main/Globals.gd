extends Node

## Variable to let the maih scene and player know if we're loading from the login scene
var loaded_from_login := false

## User Account variables
var account_credits: int = 0
var account_mininglaser: int = 0
var account_cargoextender: int = 0
var account_cargohold: int = 0
var account_position: Vector2 = Vector2()
var account_username: String = ""
var station_trit: int = 0

func set_loaded_true(): 
	loaded_from_login = true

func set_loaded_false(): 
	loaded_from_login = false	
	
func is_game_being_loaded() -> bool:
	return loaded_from_login
	
func set_loaded_user(credits: int, mininglaser: int, cargoextender: int, cargohold: int, position: Vector2, username: String) -> void:
	account_credits = credits
	account_mininglaser = mininglaser
	account_cargoextender = cargoextender
	account_cargohold = cargohold
	account_position = position
	account_username = username

## Station tritanium is not saved in the save (YET)
func save_station_tritanium(trit: int) -> void:
	station_trit = trit	
	
func get_account_credits() -> int:
	return account_credits
	
func get_account_mininglaser() -> int:
	return account_mininglaser

func get_account_cargoextender() -> int:
	return account_cargoextender
	
func get_account_cargohold() -> int:
	return account_cargohold
	
func get_account_position() -> Vector2:
	return account_position
	
func get_account_username() -> String:
	return account_username
	
## Station tritanium is not saved in the save (YET)	
func get_station_tritanium() -> int:
	return station_trit
	
## This will save the current open (in theory...) savegame with the variables on Global
## It's not this function task to make sure Globals are up to date, though.
func save() -> bool:
	#Open a file
	var file := File.new()
	var err := file.open_encrypted_with_pass ("user://"+account_username, File.WRITE, "emeOfflineSaves")
	
	if err != OK:		
		print("Error saving!")
		return false
	
	# Create an empty savegame
	# A savegame has this structure
	# #########
	# CREDITS: 0-999999			## How many credits are there
	# MININGLASER: 1-5			## What is the Mining Laser installed, from 1 to 5
	# CARGOHOLDEXT: 0-5			## What is the cargo Extender upgrade installed, from 0 to 5.
	# CARGOVELDSPAR: 0-99999	## How much veldspar is in the cargo hold, if any
	# POSITION: (0,0)			## The last position. It should be nearby the station at the beginning of the game.
	# USERNAME: name			## The username (name of the sav, minus extension)
	# #########
	
	file.store_line(str(account_credits))		# Credits
	file.store_line(str(account_mininglaser))		# Mining Laser 
	file.store_line(str(account_cargoextender))		# Cargo Extender
	file.store_line(str(account_cargohold))		# Cargo hold 
	file.store_line(str(account_position))	# position
	file.store_line(str(account_username))	# Username
	return true
	
func save_to_Globals(creds: int, minlaser: int, cargoxt: int, cargohol: int, pos: Vector2) -> void:
	account_credits = creds
	account_mininglaser = minlaser
	account_cargoextender = cargoxt
	account_cargohold = cargohol
	account_position = pos
