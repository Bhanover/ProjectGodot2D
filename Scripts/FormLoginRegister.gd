# FormLoginRegister.gd
extends Control

# Inicializa variables para los elementos de la interfaz de usuario
onready var username_input = $UsernameLineEdit
onready var password_input = $PasswordLineEdit
onready var message_label = $MessageLabel
onready var http_request = $HTTPRequest

# Conectar la señal de solicitud HTTP completada
func _ready():
	http_request.connect("request_completed", self, "_on_request_completed")

# Manejador del botón de registro
func _on_RegisterButton_pressed():
	print("Presionando register")
	enviar_peticion("registrar", username_input.text, password_input.text)

# Manejador del botón de inicio de sesión
func _on_LoginButton_pressed():
	print("Presionando login")
	enviar_peticion("iniciar_sesion", username_input.text, password_input.text)

# Enviar peticiones de registro o inicio de sesión
func enviar_peticion(accion, username, password):
	var url = "http://127.0.0.1:8000/" + accion
	var datos = {"username": username, "password": password}
	http_request.request(url, [], true, HTTPClient.METHOD_POST, JSON.print(datos))

# Procesar la respuesta del servidor
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if response.error == OK and response_code == 200:
		if response.result.mensaje == "Inicio de sesión exitoso":
			Session.set_user_name(username_input.text)  # Guardar el nombre de usuario
			cambiar_a_iniciar_juego()
		else:
			display_message("Respuesta: " + response.result.mensaje)
	else:
		display_message("Error: " + str(response_code))

# Cambiar a la escena del juego
func cambiar_a_iniciar_juego():
	get_tree().change_scene("res://Scenes/IniciarJuego.tscn")

# Mostrar mensajes en la interfaz de usuario
func display_message(text):
	message_label.text = text

