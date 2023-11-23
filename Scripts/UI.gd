extends CanvasLayer

var coins = 1
func _ready():
	$CoinsCollectedText.text = String(coins)
