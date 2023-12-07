# Player.gd

# Extiende KinematicBody2D para utilizar físicas 2D
extends KinematicBody2D

# Variables de estado del jugador
var vidas = 2  # Cantidad de vidas del jugador
var invulnerable = false  # Estado de invulnerabilidad del jugador
var tiempo_invulnerabilidad = 2.0  # Duración de la invulnerabilidad en segundos
var menu_activo = false

# Constantes para controlar movimiento y físicas del personaje
const sprintSpeed = 150  # Velocidad de sprint
const moveSpeed = 75  # Velocidad de movimiento normal
const maxSpeed = 135  # Velocidad máxima
const max_jumps = 2  # Máximo número de saltos permitidos
const jumpHeight = 300  # Altura del salto
const up = Vector2(0, -1)  # Vector de dirección hacia arriba
const gravity = 15  # Fuerza de gravedad

# Nodos cargados en tiempo de ejecución
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var http_request = $HTTPRequest
onready var message_label = $MessageLabel
onready var respawn_point = get_node("/root/Mundo/RespawnPoint")
 
# Variables de movimiento
var motion = Vector2()  # Vector de movimiento
var current_speed = 0  # Velocidad actual
var target_speed = 0  # Velocidad objetivo
const acceleration_rate = 0.5  # Tasa de aceleración
var jump_count = 0
 
onready var menu_pause = get_node("/root/Mundo/PauseMenu")
 
 
# Procesamiento de la física en cada frame
func _physics_process(delta):
	if  !menu_activo:
		menu_pause.visible = false
		motion.y += gravity  # Aplicar gravedad
		var friction = false  # Flag para fricción

		if Input.is_action_just_pressed("ui_pause"):
			pausar_juego()
		
		# Control de movimiento horizontal basado en la entrada del jugador
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

		# Aumentar la velocidad al sprintar
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

		
		# Resetear contador de saltos al tocar el suelo
		if is_on_floor() and motion.y > 0:
			jump_count = 0

		# Aplicar fricción
		if friction:
			if is_on_floor():
				motion.x = lerp(motion.x, 0, 0.5)
			else:
				motion.x = lerp(motion.x, 0, 0.01)
		
		# Mover al jugador con el movimiento calculado
		motion = move_and_slide(motion, up)
 

 
 
func pausar_juego():
	print("juego pausado")
	menu_pause.visible = true
	menu_activo = true
	get_tree().paused = true


# Función para manejar la recolección de monedas
func add_coin():
	var canvasLayer = get_tree().get_root().find_node("CanvasLayer", true, false)
	canvasLayer.handleCoinCollected()


# Función para detectar colisión y manejar daño
func _on_Splites_body_entered(body):
	if body.get_name() == "Player":
		print("nos hemos pinchado")
		_loseLife()

# Nodo para efecto visual durante invulnerabilidad
onready var pantalla_roja = get_node("/root/Mundo/PantallaRoja/ColorRect")

# Configuración inicial del nodo
func _ready():
	if http_request.is_connected("request_completed", self, "_on_HTTPRequest_request_completed"):
		print("Señal conectada correctamente.")
	else:
		print("Error al conectar la señal.")
	pantalla_roja.modulate.a = 0
func set_lives_to_zero():
	vidas = 0
# Función para perder una vida y manejar consecuencias
onready var control = get_node("/root/Mundo/MenuVidas")
 
func actualizar_etiquetas_vidas(vidas_gastadas, vidas_restantes):
	print("gola")
	print(control)
	# Obtén las etiquetas de vidas gastadas y vidas restantes desde el nodo control_panel
	var label_vidas_gastadas = control.get_node("LabelVidasGastadas")
	var label_vidas_restantes = control.get_node("LabelVidasRestantes")
 
 
	# Actualiza el texto de las etiquetas
	label_vidas_gastadas.text = "Vidas Gastadas: " + str(vidas_gastadas)
	label_vidas_restantes.text = "Vidas Restantes: " + str(vidas_restantes)

func _loseLife():
	if invulnerable:
		return
	vidas -= 1
	if vidas <= 0:
		print("Juego terminado")
		 
		respawn_player()  # Lógica para reiniciar el juego o volver al inicio
		actualizar_vidas_en_servidor()
		


	else:
		hacer_invulnerable()
		iniciar_parpadeo()

# Función para reiniciar la posición del jugador
func respawn_player():
	self.global_position = respawn_point.global_position
	vidas = 2  # Restablecer vidas
	_on_Temporizador_timeout()
# Función para actualizar vidas en el servidor
func actualizar_vidas_en_servidor():
	var url = "http://127.0.0.1:8000/actualizar_vidas"
	var datos = {"username": Session.get_user_name(), "vidas_gastadas": 1}
	http_request.request(url, [], true, HTTPClient.METHOD_POST, JSON.print(datos))

# Manejo de respuestas HTTP
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())

	# Comprobar si el análisis fue exitoso
	if response.error == OK:
		var data = response.result

	
		if response_code == 200:
			if "vidas_totales_gastadas" in data:
				var vidas_totales_gastadas = data["vidas_totales_gastadas"]
				var vidas_restantes = data["vidas_restantes"]
				print(vidas_totales_gastadas)
				
				actualizar_etiquetas_vidas(vidas_totales_gastadas, vidas_restantes)
				mostrar_panel_temporalmente()
			else:
				display_message("Respuesta exitosa, pero no se encontró la clave esperada en la respuesta.")
		else:
			if "mensaje" in data:
				display_message("Error: " + str(response_code) + " - " + data["mensaje"])
			else:
				display_message("Error: " + str(response_code) + " - Respuesta desconocida")
	else:
		print("Error al parsear JSON: ", response.error)
 

# Función para mostrar mensajes en pantalla
func display_message(text):
	message_label.text = text

# Función para hacer al jugador invulnerable temporalmente
func hacer_invulnerable():
	invulnerable = true
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_callback(self, tiempo_invulnerabilidad, "terminar_invulnerabilidad")
	tween.start()
func mostrar_panel_temporalmente():
	control.visible = true
	menu_activo = true
	var temporizador = Timer.new()
	temporizador.wait_time = 5  # 5 segundos
	temporizador.one_shot = true  # Solo se ejecuta una vez
	temporizador.connect("timeout", self, "_on_Temporizador_timeout")
	add_child(temporizador)
	temporizador.start()

func _on_Temporizador_timeout():
	control.visible = false
	menu_activo = false

# Función para iniciar un efecto de parpadeo durante la invulnerabilidad
func iniciar_parpadeo():
	var tween_rojo = Tween.new()
	add_child(tween_rojo)
	var duracion_parpadeo = 0.2
	var veces = tiempo_invulnerabilidad / duracion_parpadeo
	for i in range(int(veces)):
		tween_rojo.interpolate_property(pantalla_roja, "modulate:a", 0.5, 0, duracion_parpadeo, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, i * duracion_parpadeo)
		tween_rojo.interpolate_property(pantalla_roja, "modulate:a", 0, 0.5, duracion_parpadeo, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, i * duracion_parpadeo + duracion_parpadeo * 0.5)
	tween_rojo.interpolate_property(pantalla_roja, "modulate:a", 0.5, 0, duracion_parpadeo, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, tiempo_invulnerabilidad)
	tween_rojo.start()

# Función para terminar el estado de invulnerabilidad
func terminar_invulnerabilidad():
	invulnerable = false
	pantalla_roja.modulate.a = 0  # Restaurar la opacidad





 





func _on_Continue_pressed():
	print("Continuar presionado")
	menu_pause.visible = false
	menu_activo = false
	get_tree().paused = false

 
 
func _on_Salir_pressed():
	print("Salir presionado")
	get_tree().quit()
