extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var c = 0
var velocity = Vector2.ZERO



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	velocity.x = c

func _on_Player_startuem():
	print(1)
	c += 1 # Replace with function body.
