# Coin2D.gd
extends Area2D

signal coinCollected

var initial_position
onready var coin_sound = $AudioCoin2D

func _ready():
	add_to_group("coins_group")
	initial_position = global_position

func _on_Coin2D_body_entered(body):
	if body.name == "Player":
		body.add_coin()
		emit_signal("coinCollected")

		# Reproduce el sonido solo si no se está reproduciendo actualmente
		if not coin_sound.playing:
			coin_sound.play()

		hide()  # Ocultar la moneda
		set_collision_layer_bit(0, false)  # Desactivar la capa de colisión
		set_collision_mask_bit(0, false)  # Desactivar la máscara de colisión

# Función para reiniciar la moneda
func reset_coin():
 
	global_position = initial_position
	show()  # Mostrar la moneda
	set_collision_layer_bit(0, true)  # Reactivar la capa de colisión
	set_collision_mask_bit(0, true)  # Reactivar la máscara de colisión
