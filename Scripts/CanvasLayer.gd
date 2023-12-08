#CanvasLayer.gd
extends CanvasLayer

var coins = 0

func _ready():
	# Conectar el signal 'coinCollected' del nodo Coin2D al método 'handleCoinCollected'

	# Actualizar el texto de monedas recolectadas
	$CoinsCollectedText.text = str(coins)

func handleCoinCollected(new_coin_count):
	print("Coin Collected")
	coins = new_coin_count
	$CoinsCollectedText.text = str(coins) # Actualizar el contador de monedas en la UI
