# Vida2D.gd
extends Area2D

signal vidaCollected

var initial_position
onready var vida_sound = $AudioVida2D

func _ready():
	add_to_group("vidas_group")
	initial_position = global_position

func _on_Vida2D_body_entered(body):
	if body.name == "Player":
		body.add_vida()  # Cambiar a 'add_vida()'
		emit_signal("vidaCollected")

		if not vida_sound.playing:
			vida_sound.play()

		hide()  # Ocultar el ícono de vida
		set_collision_layer_bit(0, false)  # Desactivar la capa de colisión
		set_collision_mask_bit(0, false)  # Desactivar la máscara de colisión


# Función para reiniciar la moneda
func reset_coin():
 
	global_position = initial_position
	show()  # Mostrar la moneda
	set_collision_layer_bit(0, true)  # Reactivar la capa de colisión
	set_collision_mask_bit(0, true)  # Reactivar la máscara de colisión


 
