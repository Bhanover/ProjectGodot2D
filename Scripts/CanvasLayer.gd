#CanvasLayer.gd
extends CanvasLayer



var coins = 0
var vidas = 0
onready var http_request_vidas = $HTTPRequestVidas

func _ready():
	$CoinsCollectedText.text = str(coins)
	obtener_vidas_actuales()
	http_request_vidas.connect("request_completed", self, "_on_HTTPRequestVidas_request_completed")

func obtener_vidas_actuales():
	var username = Session.get_user_name()
	var url = "http://127.0.0.1:8000/obtener_vidas_actuales?username=" + username
	http_request_vidas.request(url, [], false, HTTPClient.METHOD_GET)

func _on_HTTPRequestVidas_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if response.error == OK and response_code == 200:
		vidas = response.result["vidas_actuales"]
		$VidaCollectedText.text = str(vidas)
	else:
		print("Error al recibir datos:", response.error)
		
func handleCoinCollected(new_coin_count):
	print("Coin Collected")
	coins = new_coin_count
	$CoinsCollectedText.text = str(coins) # Actualizar el contador de monedas en la UI
func handleVidaCollected(new_vida_count):
	print("Vida Collected")
	vidas = new_vida_count
	$VidaCollectedText.text = str(vidas)

