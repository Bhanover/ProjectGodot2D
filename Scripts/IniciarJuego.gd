#IniciarJuego.gd
extends Control



func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scenes/Mundo.tscn")
