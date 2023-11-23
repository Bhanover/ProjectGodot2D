
# Clase para el área que detecta la recogida de monedas
extends Area2D

signal coinCollected

func _on_Coin2D_body_entered(body):
	if body.name == "Player":
		body.add_coin()
		emit_signal("coinCollected")
		queue_free()
