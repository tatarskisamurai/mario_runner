extends Label

var coins = 0

func _process(delta):
	text = str(coins)

func _on_Coin_collected():
	coins += 1
	print('1')
