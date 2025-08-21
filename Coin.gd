extends Node2D

signal collected


func _on_CoinArea_body_entered(body):
	if body.name == 'Player':
		queue_free()
		emit_signal("collected")
