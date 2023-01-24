extends Node

## Variable to let the maih scene and player know if we're loading from the login scene
var loaded_from_login := false

## User Account variables
var account_credits: int = 0
var account_mininglaser: int = 0
var account_cargoextender: int = 0
var account_cargohold: int = 0
var account_position: Vector2 = Vector2()

func set_loaded_true(): 
	loaded_from_login = true

func set_loaded_false(): 
	loaded_from_login = false	
	
func is_game_being_loaded() -> bool:
	return loaded_from_login
	
func set_loaded_user(credits: int, mininglaser: int, cargoextender: int, cargohold: int, position: Vector2) -> void:
	account_credits = credits
	account_mininglaser = mininglaser
	account_cargoextender = cargoextender
	account_cargohold = cargohold
	account_position = position
	
func get_account_credits() -> int:
	return account_credits
	
func get_account_mininglaser() -> int:
	return account_mininglaser

func get_account_cargoextender() -> int:
	return account_cargoextender
	
func get_account_cargohold() -> int:
	return account_cargoextender
	
func get_account_position() -> Vector2:
	return account_position
