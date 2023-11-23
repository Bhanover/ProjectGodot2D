extends CanvasLayer

var coins = 0

func _ready():
	# Conectar el signal 'coinCollected' del nodo Coin2D al método 'handleCoinCollected'

	# Actualizar el texto de monedas recolectadas
	$CoinsCollectedText.text = str(coins)

func handleCoinCollected():
	print("Coin Collected")
	coins += 1
	$CoinsCollectedText.text = str(coins) # Actualizar el contador de monedas en la UI
	
	if coins == 3:
		get_tree().change_scene("res://Scenes/Mundo" + str(int(get_tree().current_scene.name)+1)+".tscn")
