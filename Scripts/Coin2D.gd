extends Area2D

signal coinColleted


func _on_Coin2D_body_entered(body):
	emit_signal("coinColleted")
	if body.get_name() == "Player":
		queue_free()
		pass # Replace with function body.
