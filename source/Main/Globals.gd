extends Node

## Variable to let the maih scene and player know if we're loading from the login scene
var loaded_from_login := false

func set_loaded_true(): 
	loaded_from_login = true

func set_loaded_false(): 
	loaded_from_login = false	
	
func is_game_being_loaded() -> bool:
	return loaded_from_login
