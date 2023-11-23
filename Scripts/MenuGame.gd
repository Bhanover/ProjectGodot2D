extends Control




# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/StarGameButton.grab_focus()







func _on_QuitGameButton_pressed():
	get_tree().quit()




func _on_StarGameButton_pressed():
		get_tree().change_scene("res://Scenes/Mundo.tscn")
