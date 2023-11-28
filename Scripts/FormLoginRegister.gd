extends Control

onready var username_input = $UsernameLineEdit
onready var password_input = $PasswordLineEdit
onready var message_label = $MessageLabel
onready var http_request = $HTTPRequest

func _ready():
	http_request.connect("request_completed", self, "_on_request_completed")

func _on_RegisterButton_pressed():
	print("presionando register")
	enviar_registro(username_input.text, password_input.text)

func _on_LoginButton_pressed():
	print("presionando login")
	enviar_login(username_input.text, password_input.text)

func enviar_registro(username, password):
	var url = "http://127.0.0.1:8000/registrar"
	var datos = {"username": username, "password": password}
	http_request.request(url, [], true, HTTPClient.METHOD_POST, JSON.print(datos))

func enviar_login(username, password):
	var url = "http://127.0.0.1:8000/iniciar_sesion"
	var datos = {"username": username, "password": password}
	http_request.request(url, [], true, HTTPClient.METHOD_POST, JSON.print(datos))

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if response_code == 200:
		if response.result.mensaje == "Inicio de sesión exitoso":
			Session.set_user_name(username_input.text)  # Guardar el nombre de usuario
			cambiar_a_iniciar_juego()
		else:
			display_message("Respuesta: " + response.result.mensaje)
	else:
		display_message("Error: " + str(response_code))


func cambiar_a_iniciar_juego():
	get_tree().change_scene("res://Scenes/IniciarJuego.tscn")

func display_message(text):
	message_label.text = text


