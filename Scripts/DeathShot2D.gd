#Script DeathShot2D
extends Area2D
var vidas
func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		print("Nos estamos cayendo")
		body.set_lives_to_zero()  # Establece las vidas del jugador a 0
		body._loseLife(true)  # Añade 'true' para indicar que es una caída

