#Script Player
extends KinematicBody2D


var vidas = 2
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
onready var http_request = $HTTPRequest
var current_speed = 0
var target_speed = 0
const acceleration_rate = 0.5  
onready var message_label = $MessageLabel
onready var respawn_point = get_node("/root/Mundo/RespawnPoint")

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

onready var pantalla_roja = get_node("/root/Mundo/PantallaRoja/ColorRect")
func _ready():
	if http_request.is_connected("request_completed", self, "_on_HTTPRequest_request_completed"):
		print("Señal conectada correctamente.")
	else:
		print("Error al conectar la señal.")
	pantalla_roja.modulate.a = 0

func _loseLife():
	if invulnerable:
		return

	print("Nos hemos pinchado, perdemos vida")
	vidas -= 1
	if vidas <= 0:
		print("Juego terminado")
		respawn_player()  # Lógica para reiniciar el juego o volver al inicio
		actualizar_vidas_en_servidor()
	else:
		hacer_invulnerable()
		iniciar_parpadeo()

func respawn_player():
	# Mover al jugador al punto de reaparición
	self.global_position = respawn_point.global_position
	# Restablecer vidas o cualquier otro estado necesario
	vidas = 2  # O el número que corresponda
	#get_tree().reload_current_scene()

func actualizar_vidas_en_servidor():
	var url = "http://127.0.0.1:8000/actualizar_vidas"
	print( "nombre del usuario "+Session.get_user_name())
	var datos = {"username": Session.get_user_name(), "vidas_gastadas": 1}
	print(url)
	http_request.request(url, [], true, HTTPClient.METHOD_POST, JSON.print(datos))
	print("Estado de la petición HTTP: ", http_request.get_http_client_status())



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("dentro")
	var response = JSON.parse(body.get_string_from_utf8())
	if response_code == 200:
		if "vidas_totales gastadas" in response:
			print("Vidas totales actualizadas: ", response["vidas_totales gastadas"])
		else:
			display_message("Respuesta exitosa, pero no se encontró la clave esperada en la respuesta.")
	else:
		if "mensaje" in response:
			display_message("Error: " + str(response_code) + " - " + response["mensaje"])
		else:
			display_message("Error: " + str(response_code) + " - Respuesta desconocida")




func display_message(text):
	message_label.text = text




 
func hacer_invulnerable():
	invulnerable = true
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_callback(self, tiempo_invulnerabilidad, "terminar_invulnerabilidad")
	tween.start()

func iniciar_parpadeo():
	var tween_rojo = Tween.new()
	add_child(tween_rojo)
	var duracion_parpadeo = 0.2  # Duración de cada parpadeo
	var veces = tiempo_invulnerabilidad / duracion_parpadeo
	for i in range(int(veces)):
		tween_rojo.interpolate_property(pantalla_roja, "modulate:a", 0.5, 0, duracion_parpadeo, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, i * duracion_parpadeo)
		tween_rojo.interpolate_property(pantalla_roja, "modulate:a", 0, 0.5, duracion_parpadeo, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, i * duracion_parpadeo + duracion_parpadeo * 0.5)

	# Asegurarse de que la opacidad sea 0 al final de la invulnerabilidad
	tween_rojo.interpolate_property(pantalla_roja, "modulate:a", 0.5, 0, duracion_parpadeo, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, tiempo_invulnerabilidad)
	tween_rojo.start()


func terminar_invulnerabilidad():
	invulnerable = false
	pantalla_roja.modulate.a = 0  # Restaurar la opacidad

 

 
