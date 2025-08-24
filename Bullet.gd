# bullet.gd (отладочная версия)
extends KinematicBody2D

export var speed = 300
var direction = Vector2.RIGHT

func _ready():
	print("🔴 Пуля: создана, направление: ", direction)

func _physics_process(delta):
	var velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		print("💥 Пуля столкнулась с: ", collision.collider.name)
		queue_free()

func set_direction(dir):
	direction = dir
	print("🎯 set_direction() вызван: ", direction)
