#Script Player
extends KinematicBody2D


var vidas = 5
var invulnerable = false
var tiempo_invulnerabilidad = 2.0  # Duración de la invulnerabilidad en segundos
const sprintSpeed = 150 
const moveSpeed = 75
const maxSpeed = 135
var jump_count = 0
const max_jumps = 2
const jumpHeight = 300
const up = Vector2(0, -1)
const gravity = 15
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
var motion = Vector2()

var current_speed = 0
var target_speed = 0
const acceleration_rate = 0.5  

func _physics_process(delta):
	motion.y += gravity
	var friction = false

	# Establecer la velocidad objetivo basada en la entrada del jugador
	if Input.is_action_pressed("ui_right"):
		target_speed = moveSpeed
		sprite.flip_h = true
		animationPlayer.play("Walk")
	elif Input.is_action_pressed("ui_left"):
		target_speed = -moveSpeed
		sprite.flip_h = false
		animationPlayer.play("Walk")
	else:
		target_speed = 0
		animationPlayer.play("Idle")
		friction = true

	# Ajustar para sprint
	if Input.is_action_pressed("ui_sprint"):
		target_speed *= sprintSpeed / moveSpeed

	# Aceleración y desaceleración progresivas
	current_speed = lerp(current_speed, target_speed, acceleration_rate)

	# Aplicar movimiento horizontal
	motion.x = lerp(motion.x, current_speed, delta)

	# Salto
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			motion.y = -jumpHeight
			jump_count = 1  # Reiniciar a 1 porque este es el primer salto
		elif jump_count < max_jumps:
			motion.y = -jumpHeight
			jump_count += 1

	if is_on_floor() and motion.y > 0:
		jump_count = 0


	# Fricción
	if friction:
		if is_on_floor():
			motion.x = lerp(motion.x, 0, 0.5)
		else:
			motion.x = lerp(motion.x, 0, 0.01)
	
	# Aplicar movimiento
	motion = move_and_slide(motion, up)

func add_coin():
	var canvasLayer = get_tree().get_root().find_node("CanvasLayer", true, false)
	canvasLayer.handleCoinCollected()

#Damage
func _on_Splites_body_entered(body):
	if body.get_name() == "Player":
		print("nos hemos pinchado")
		_loseLife()
	
func _loseLife():
	if invulnerable:
		return

	print("Nos hemos pinchado, perdemos vida")
	vidas -= 1
	if vidas <= 0:
		print("Juego terminado")
		# Lógica para terminar el juego o reiniciar
	else:
		hacer_invulnerable()

func hacer_invulnerable():
	invulnerable = true
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(sprite, "modulate", sprite.modulate, Color(1, 1, 1, 0.5), tiempo_invulnerabilidad, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_callback(self, tiempo_invulnerabilidad, "terminar_invulnerabilidad")
	tween.start()

func terminar_invulnerabilidad():
	invulnerable = false
	sprite.modulate = Color(1, 1, 1, 1)  # Restaurar la opacidad


