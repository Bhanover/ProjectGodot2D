extends Area2D

func _ready():
	connect("area_entered", self, "_on_Fin2D_area_entered")




func _on_Fin2D2_body_entered(body):
	print("Área ingresada")  # Solo para propósitos de depuración
	if body.is_in_group("Player"):
		get_tree().change_scene("res://Scenes/Mundo2.tscn")

 
