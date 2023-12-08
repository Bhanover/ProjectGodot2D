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
onready var http_request_coins = $HTTPRequestCoins
onready var http_request_suma_vida = $HTTPRequestSumaVida
onready var message_label = $MessageLabel
onready var respawn_point = get_node("/root/Mundo/RespawnPoint")
onready var music_player = get_node("/root/Mundo/MusicMundo")
onready var damage_sound = $DamageSound
onready var death_sound = $DeathSound
# Variables de movimiento
var motion = Vector2()  # Vector de movimiento
var current_speed = 0  # Velocidad actual
var target_speed = 0  # Velocidad objetivo
const acceleration_rate = 0.5  # Tasa de aceleración
var jump_count = 0
var coins = 0
var max_coins_record = 0
onready var menu_pause = get_node("/root/Mundo/PauseMenu")
onready var menu_pause_volumen = get_node("/root/Mundo/PauseMenu/PanelVolumen") 
onready var slider_volumen =  get_node("/root/Mundo/PauseMenu/PanelVolumen/SliderVolumen") 
onready var boton_silencio = get_node("/root/Mundo/PauseMenu/PanelVolumen/BotonSilencio")

var volumen_anterior = 0.0
var esta_silenciado = false
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
signal vidas_actualizadas(new_vida_count)
func add_coin():
	coins += 1 
	var canvasLayer = get_tree().get_root().find_node("CanvasLayer", true, false)

	if canvasLayer:
		canvasLayer.handleCoinCollected(coins) 
func add_vida():
	vidas += 1  # Incrementar vidas
	var canvasLayer = get_tree().get_root().find_node("CanvasLayer", true, false)
	if canvasLayer:
		canvasLayer.handleVidaCollected(vidas)  # Actualizar el contador de vidas en la UI
	sumar_vida_en_servidor()
func _on_HTTPRequestSumaVida_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if response.error == OK and response_code == 200:
		var new_vida_count = response.result["vidas_actuales"]
		print("Respuesta del servidor:", response.result)
		var canvasLayer = get_tree().get_root().find_node("CanvasLayer", true, false)
		if canvasLayer:
			canvasLayer.handleVidaCollected(new_vida_count)
	else:
		print("Error al recibir datos:", response.error)
func sumar_vida_en_servidor():
	var url = "http://127.0.0.1:8000/sumar_vida"  # Asegúrate de que la URL es correcta
	var datos = {"username": Session.get_user_name()}
	var headers = ["Content-Type: application/json"]
	http_request_suma_vida.request(url, headers, true, HTTPClient.METHOD_POST, JSON.print(datos))
# Función para manejar la recolección de monedas
 

# Función para detectar colisión y manejar daño
func _on_Splites_body_entered(body):
	if body.get_name() == "Player":
		print("nos hemos pinchado")
		_loseLife()

# Nodo para efecto visual durante invulnerabilidad
onready var pantalla_roja = get_node("/root/Mundo/PantallaRoja/ColorRect")

# Configuración inicial del nodo
func _ready():
	add_to_group("Player")
	if http_request.is_connected("request_completed", self, "_on_HTTPRequest_request_completed"):
		print("Señal conectada correctamente.")
	else:
		print("Error al conectar la señal.")
	http_request_coins.connect("request_completed", self, "_on_HTTPRequestCoins_request_completed")
	http_request.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	menu_pause_volumen.connect("pressed", self, "_on_BotonConfiguracionVolumen_pressed")
	slider_volumen.connect("value_changed", self, "_on_SliderVolumen_value_changed")
	boton_silencio.connect("pressed", self, "_on_BotonSilencio_pressed")
	http_request_suma_vida.connect("request_completed", self, "_on_HTTPRequestSumaVida_request_completed")

	 # Configuración inicial del volumen
	var volumen_inicial = 0 # Ajusta esto al nivel de volumen inicial deseado
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volumen_inicial)
	slider_volumen.value = volumen_inicial
	volumen_anterior = volumen_inicial
	pantalla_roja.modulate.a = 0
func set_lives_to_zero():
	vidas = 0
# Función para perder una vida y manejar consecuencias
onready var control = get_node("/root/Mundo/MenuVidas")
 
func actualizar_etiquetas_vidas(vidas_gastadas, vidas_restantes):
	print("gola")
	print(control)
	# Obtén las etiquetas de vidas gastadas y vidas restantes desde el nodo control_panel
	var label_vidas_gastadas = control.get_node("Panel/LabelVidasGastadas")
	var label_vidas_restantes = control.get_node("Panel/LabelVidasRestantes")
 
 
	# Actualiza el texto de las etiquetas
	label_vidas_gastadas.text = "Vidas Gastadas: " + str(vidas_gastadas)
	label_vidas_restantes.text = "Vidas Restantes: " + str(vidas_restantes)

func _loseLife(caida = false):
	if invulnerable and not caida:
		return
	vidas -= 1
	damage_sound.play()
	if vidas <= 0:
		# Detiene la música inmediatamente
		music_player.stop()
		death_sound.play() 
		# Actualizar estadísticas, reiniciar monedas, etc.
		actualizar_estadisticas_en_servidor()
	 
		actualizar_vidas_en_servidor()
		print("Juego terminado")
		reset_coins()
		reset_coins_ui() 
		respawn_player()
 
		# Inicia un temporizador para esperar 5 segundos antes de reiniciar la música
		 # Establece un temporizador para reiniciar la música
		var temporizador_musica = Timer.new()
		temporizador_musica.wait_time = 6  # 5 segundos
		temporizador_musica.one_shot = true
		temporizador_musica.connect("timeout", self, "_on_TemporizadorMusica_timeout")
		add_child(temporizador_musica)
		temporizador_musica.start()
	 


	else:
		hacer_invulnerable()
		iniciar_parpadeo()
# Función para reiniciar las monedas
 
func actualizar_estadisticas_en_servidor():
	max_coins_record = max(coins, max_coins_record)
	var url = "http://127.0.0.1:8000/actualizar_estadisticas"
	var datos = {
		"username": Session.get_user_name(),
		"oro_recolectado": coins,  # Cantidad de monedas recolectadas hasta la muerte en la partida actual
		"mayor_coins_en_una_partida": max_coins_record
	}
	var headers = ["Content-Type: application/json"]
	http_request_coins.request(url, headers, true, HTTPClient.METHOD_POST, JSON.print(datos))
	coins = 0  # Reiniciar el contador de monedas
	

func _on_HTTPRequestCoins_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if response.error == OK and response_code == 200:
		print("Datos recibidos correctamente. Respuesta del servidor:", response.result)
		if "mensaje" in response.result:
			print(response.result["mensaje"])
		if "oro_recolectado" in response.result and "oro_recolectado_total" in response.result and "mayor_oro_en_una_partida" in response.result:
			actualizar_etiquetas_moneda(response.result)
	else:
		print("Error al recibir datos:", response.error)

func actualizar_etiquetas_moneda(datos):
	var monedas_actuales = datos["oro_recolectado"]
	var monedas_totales = datos["oro_recolectado_total"]
	var max_monedas = datos["mayor_oro_en_una_partida"]

	var label_coin = control.get_node("Panel/LabelCoin")
	var label_coin_total = control.get_node("Panel/LabelCoinTotal")
	var label_max_coin = control.get_node("Panel/LabelMaxCoin")

	label_coin.text = "Monedas Actuales: " + str(monedas_actuales)
	label_coin_total.text = "Monedas Totales: " + str(monedas_totales)
	label_max_coin.text = "Máximo de Monedas en una Partida: " + str(max_monedas)


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
func reset_coins():

	var coins = get_tree().get_nodes_in_group("coins_group")  # Asegúrate de que tus monedas estén en este grupo

	for coin in coins:

		coin.reset_coin()
		
func reset_coins_ui():
	var canvasLayer = get_tree().get_root().find_node("CanvasLayer", true, false)
	if canvasLayer:
		canvasLayer.handleCoinCollected(0)  # Reinicia el contador de monedas en la UI

# Manejo de respuestas HTTP
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())

	# Comprobar si el análisis fue exitoso
	if response.error == OK:
		var data = response.result
		print("Datos recibidos correctamente. Respuesta del servidor:", response.result)
	
		if response_code == 200:
			if "vidas_totales_gastadas" in data:
				var vidas_totales_gastadas = data["vidas_totales_gastadas"]
				var vidas_restantes = data["vidas_restantes"]
				print(vidas_totales_gastadas)
				print("vidas")
				var canvasLayer = get_tree().get_root().find_node("CanvasLayer", true, false)
				canvasLayer.handleVidaCollected(vidas_restantes)
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
	print("hola estoy en panel temporal")
	menu_activo = true
	var temporizador = Timer.new()
	temporizador.wait_time = 6  # 5 segundos
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

 


func _on_TemporizadorMusica_timeout():
	death_sound.stop()
	music_player.play()  


func _on_BotonConfiguracionVolumen_pressed():
	menu_pause_volumen.visible = true

func _on_SliderVolumen_value_changed(value):
	if esta_silenciado:
		esta_silenciado = false
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	volumen_anterior = value


func _on_BotonSilencio_pressed():
	if esta_silenciado:
		slider_volumen.value = volumen_anterior
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volumen_anterior)
		esta_silenciado = false
	else:
		volumen_anterior = slider_volumen.value  # Guardar el valor del slider antes de silenciar
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80.0)  # Silenciar completamente
		slider_volumen.value = -80.0
		esta_silenciado = true

func _on_VolverMenu_pressed():
	menu_pause_volumen.visible = false
