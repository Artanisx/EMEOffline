extends CanvasLayer

var mining_button_hover: bool = false

func _on_MiningButton_mouse_entered():
	mining_button_hover = true

func _on_MiningButton_mouse_exited():
	mining_button_hover = false
