extends CanvasLayer

var coins = 0
func _ready():
	var coinNode = get_tree().get_root().find_node("Coin2D",true,false)
	coinNode.connect("coinColleted",self,"handleCoinCollected")
	$CoinsCollectedText.text = String(coins)

func handleCoinCollected():
	print("Coin Colleted")
	coins+=1
